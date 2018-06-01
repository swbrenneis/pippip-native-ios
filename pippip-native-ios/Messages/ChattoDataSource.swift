//
//  ChattoDataSource.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Chatto
import ChattoAdditions
import AudioToolbox

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
        return slidingWindow.items
    }
    var visible: Bool = false {
        didSet {
            slidingWindow.visible = visible
        }
    }
    var delegate: ChatDataSourceDelegateProtocol?
    var slidingWindow: SlidingMessageWindow

    init(conversation: Conversation) {

        slidingWindow = SlidingMessageWindow(conversation: conversation, windowSize: 15)

        NotificationCenter.default.addObserver(self, selector: #selector(newMessages(_:)),
                                               name: Notifications.NewMessages, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(messageSent(_:)),
                                               name: Notifications.MessageSent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cleartextAvailable(_:)),
                                               name: Notifications.CleartextAvailable, object: nil)

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
        delegate?.chatDataSourceDidUpdate(self, updateType: .normal)

    }

    func clearMessages() {

        assert(Thread.isMainThread, "clearMessages not called from main thread")
        slidingWindow.clearMessages()
        delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)

    }

    // Notifications
    
    // This is sent from the main thread
    @objc func messageSent(_ notification: Notification) {

        assert(Thread.isMainThread, "Message sent notification must be sent from main thread")
        guard let messageId = notification.object as? Int64 else { return }
        slidingWindow.messageSent(messageId)
        delegate?.chatDataSourceDidUpdate(self, updateType: .normal)

    }

    @objc func newMessages(_ notification: Notification) {

        guard let textMessages = notification.object as? [TextMessage]else { return }
        DispatchQueue.main.async {
            if self.visible && self.slidingWindow.newMessages(textMessages) {
                self.delegate?.chatDataSourceDidUpdate(self, updateType: .normal)
                AudioServicesPlaySystemSound(MessageManager.receiveSoundId)
            }
        }

    }

    @objc func cleartextAvailable(_ notification: Notification) {

        guard  let textMessage = notification.object as? TextMessage else { return }
        if visible {
            DispatchQueue.main.async {
                self.slidingWindow.updateChatItem(textMessage)
                self.delegate?.chatDataSourceDidUpdate(self, updateType: .reload)
            }
        }

    }

}
