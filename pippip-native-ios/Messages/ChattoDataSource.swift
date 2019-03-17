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
            return conversation?.canSlideDown() ?? false
        }
    }
    var hasMorePrevious: Bool {
        get {
            return conversation?.canSlideUp() ?? false
        }
    }
    var chatItems: [ChatItemProtocol] {
        return conversation?.items ?? [ChatItemProtocol]()
    }
    var visible: Bool = false {
        didSet {
            conversation?.visible = visible
        }
    }
    var delegate: ChatDataSourceDelegateProtocol?
    var conversation: Conversation?

    init(conversation: Conversation?) {

        self.conversation = conversation
        visible = true
        conversation?.visible = true
        addObservers()

    }

    func addObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(newMessages(_:)),
                                               name: Notifications.NewMessages, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(messageDeleted(_:)),
                                               name: Notifications.MessageDeleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(messageFailed(_:)),
                                               name: Notifications.MessageFailed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(messageSent(_:)),
                                               name: Notifications.MessageSent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cleartextAvailable(_:)),
                                               name: Notifications.CleartextAvailable, object: nil)
        
    }

    func loadNext() {
        conversation?.slideDown()
        delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
    }
    
    func loadPrevious() {
        conversation?.slideUp()
        delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
    }
    
    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion: (Bool) -> Void) {

        completion(false)

    }
    
    func addTextMessage(_ textMessage: TextMessage) {

        conversation?.addTextMessage(textMessage, initial: false)
        delegate?.chatDataSourceDidUpdate(self, updateType: .normal)

    }

    func clearMessages() {

        assert(Thread.isMainThread, "clearMessages not called from main thread")
        conversation?.clearMessages()
        delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)

    }

    func deleteMessage(messageId: Int64) {
        
        conversation?.deleteMessage(messageId)
        delegate?.chatDataSourceDidUpdate(self, updateType: .normal)

    }

    func removeObservers() {
        
        NotificationCenter.default.removeObserver(self, name: Notifications.NewMessages, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.MessageDeleted, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.MessageFailed, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.MessageSent, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.CleartextAvailable, object: nil)

    }

    func retryTextMessage(_ textMessage: TextMessage) {

        DispatchQueue.main.async {
            self.conversation?.retryTextMessage(textMessage)
            self.delegate?.chatDataSourceDidUpdate(self, updateType: .normal)
        }

    }

    // Notifications

    @objc func cleartextAvailable(_ notification: Notification) {
        
        guard let textMessage = notification.object as? TextMessage else { return }
        DispatchQueue.main.async {
            self.conversation?.updateChatItem(textMessage: textMessage)
            self.delegate?.chatDataSourceDidUpdate(self, updateType: .reload)
        }
        
    }
    
    @objc func messageDeleted(_ notification: Notification) {
        
        assert(Thread.isMainThread, "Message deleted notification must be sent from main thread")
        guard let textMessage = notification.object as? TextMessage else { return }
        conversation?.deleteMessage(textMessage.messageId)
        delegate?.chatDataSourceDidUpdate(self, updateType: .normal)
        
    }
    
    @objc func messageFailed(_ notification: Notification) {
        
        assert(Thread.isMainThread, "Message failed notification must be sent from main thread")
        guard let textMessage = notification.object as? TextMessage else { return }
        conversation?.messageFailed(textMessage.messageId)
        delegate?.chatDataSourceDidUpdate(self, updateType: .normal)
        
    }
    
    // This is sent from the main thread
    @objc func messageSent(_ notification: Notification) {

        assert(Thread.isMainThread, "Message sent notification must be sent from main thread")
        guard let messageId = notification.object as? Int64 else { return }
        conversation?.messageSent(messageId: messageId)
        delegate?.chatDataSourceDidUpdate(self, updateType: .normal)

    }

    @objc func newMessages(_ notification: Notification) {

        guard let textMessages = notification.object as? [TextMessage] else { return }
        for message in textMessages {
            if message.contactId == conversation?.contact.contactId {
                conversation?.addTextMessage(message, initial: false)
            }
        }
        DispatchQueue.main.async {
            if self.visible {
                self.delegate?.chatDataSourceDidUpdate(self, updateType: .normal)
                AudioServicesPlaySystemSound(ChattoViewController.receiveSoundId)
            }
        }

    }

}
