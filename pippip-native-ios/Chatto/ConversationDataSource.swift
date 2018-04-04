//
//  ConversationDataSource.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation
import Chatto

class ConversationDataSource: ChatDataSourceProtocol {

    var nextMessageId: Int = 0
    var messageIds: [ NSNumber ]
    let preferredMaxWindowSize = 500
    var scrollingWindow: ScrollingDataSource<ChatItemProtocol>!
    var messageManager: MessageManager

    init(count: Int, pageSize: Int) {
        messageManager = MessageManager()
        messageIds = messageManager.getMessageIds()
        /*
        self.scrollingWindow = ScrollingDataSource(count: count, pageSize: pageSize) { () -> ChatItemProtocol in
        }
 */
    }
    
    init(messages: [ChatItemProtocol], pageSize: Int) {
        messageManager = MessageManager()
        messageIds = messageManager.getMessageIds()
        self.scrollingWindow = ScrollingDataSource(items: messages, pageSize: pageSize)
    }
    
    lazy var messageSender: ConversationMessageSender = {
        let sender = ConversationMessageSender()
        sender.onMessageChanged = { [weak self] (message) in
            guard let sSelf = self else { return }
            sSelf.delegate?.chatDataSourceDidUpdate(sSelf)
        }
        return sender
    }()
    
    var hasMoreNext: Bool {
        return self.scrollingWindow.hasMore()
    }
    
    var hasMorePrevious: Bool {
        return self.scrollingWindow.hasPrevious()
    }
    
    var chatItems: [ChatItemProtocol] {
        return self.scrollingWindow.itemsInWindow
    }
    
    weak var delegate: ChatDataSourceDelegateProtocol?
    
    func loadNext() {
        self.scrollingWindow.loadNext()
        self.scrollingWindow.adjustWindow(focusPosition: 1, maxWindowSize: self.preferredMaxWindowSize)
        self.delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
    }
    
    func loadPrevious() {
        self.scrollingWindow.loadPrevious()
        self.scrollingWindow.adjustWindow(focusPosition: 0, maxWindowSize: self.preferredMaxWindowSize)
        self.delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
    }
    
    func addTextMessage(_ text: String) {
        let uid = "\(self.nextMessageId)"
        self.nextMessageId += 1
        //let message = ConversationMessageFactory.makeTextMessage(uid, text: text, isIncoming: false)
        //self.messageSender.sendMessage(message)
        //self.scrollingWindow.insertItem(message, position: .bottom)
        self.delegate?.chatDataSourceDidUpdate(self)
    }
/*
    func addPhotoMessage(_ image: UIImage) {
        let uid = "\(self.nextMessageId)"
        self.nextMessageId += 1
        let message = ConversationMessageFactory.makePhotoMessage(uid, image: image, size: image.size, isIncoming: false)
        self.messageSender.sendMessage(message)
        self.slidingWindow.insertItem(message, position: .bottom)
        self.delegate?.chatDataSourceDidUpdate(self)
    }
*/
  func addRandomIncomingMessage() {
    /*
        let message = ConversationMessageFactory.makeRandomMessage("\(self.nextMessageId)", isIncoming: true)
        self.nextMessageId += 1
        self.scrollingWindow.insertItem(message, position: .bottom)
        self.delegate?.chatDataSourceDidUpdate(self)
 */
    }
    
    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion:(_ didAdjust: Bool) -> Void) {
        let didAdjust = self.scrollingWindow.adjustWindow(focusPosition: focusPosition, maxWindowSize: preferredMaxCount ?? self.preferredMaxWindowSize)
        completion(didAdjust)
    }
}
