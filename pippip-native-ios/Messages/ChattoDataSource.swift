//
//  ChattoDataSource.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Chatto
import ChattoAdditions

class ChattoDataSource: ChatDataSourceProtocol {

    var hasMoreNext: Bool {
        get {
            return slidingWindow.canSlideDown()
        }
    }
    var hasMorePrevious: Bool {
        get {
            return slidingWindow.canSlideUp()
        }
    }
    var chatItems: [ChatItemProtocol] {
        get {
            return chatItemFactory.makeChatItems(slidingWindow.window)
        }
    }
    var delegate: ChatDataSourceDelegateProtocol?
    var slidingWindow: SlidingMessageWindow
    var chatItemFactory: TextChatItemFactory

    init(conversation: Conversation) {

        slidingWindow = SlidingMessageWindow(conversation: conversation, windowSize: 25)
        chatItemFactory = TextChatItemFactory()

        NotificationCenter.default.addObserver(self, selector: #selector(newMessages(_:)),
                                               name: Notifications.NewMessages, object: nil)
        
    }

    func loadNext() {
        slidingWindow.slideDown()
        delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
    }
    
    func loadPrevious() {
        slidingWindow.slideUp()
        delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
    }
    
    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion: (Bool) -> Void) {

        completion(false)

    }
    
    func addTextMessage(_ textMessage: TextMessage) {

        slidingWindow.insertMessage(textMessage)
        delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)

    }

    func clearMessages() {

        assert(Thread.isMainThread, "clearMessages not called from main thread")
        slidingWindow.clearMessages()
        delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)

    }

    @objc func newMessages(_ notification: Notification) {

        DispatchQueue.main.async {
            self.slidingWindow.newMessages()
            self.delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
        }
        
    }

}
