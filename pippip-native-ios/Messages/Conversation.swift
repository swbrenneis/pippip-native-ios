//
//  Conversation.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/10/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class Conversation: NSObject {

    var contact: Contact
    var messageManager = MessageManager()
    // Sorted list, oldest first
    private var messageList = SortedArray<TextMessage>(areInIncreasingOrder: { id1, id2 in
        if id1.timestamp < id2.timestamp {
            return true
        }
        else {
            return false
        }
    })
    private var messageMap = [Int64: TextMessage]()
    var windowSize: Int
    var windowPos: Int = 0
    var loadComplete = true
    var items = [PippipTextMessageModel]()
    var visible: Bool = false {
        didSet {
            if visible {
                updateAllChatItems()
                markAllMessagesRead()
            }
        }
    }
    var mostRecentMessage: TextMessage? {
        get {
            return messageList.last
        }
    }

    init(contact: Contact, windowSize: Int) {

        self.contact = contact
        self.windowSize = windowSize

        super.init()
        // The conversation is instantiated in the summary screen, so we don't want to load all of the messages yet
        loadInitialMessages()

    }

    func acknowledgeMessage(_ message: Message) {

        messageMap[message.messageId]?.acknowledged = true;

    }

    func addTextMessage(_ textMessage: TextMessage) {
        
        if messageMap[textMessage.messageId] == nil {
            messageList.insert(textMessage)
            messageMap[textMessage.messageId] = textMessage
            if visible {
                textMessage.read = true
                messageManager.markMessageRead(messageId: textMessage.messageId)
            }
            DispatchQueue.global().async {
                textMessage.decrypt(notify: true)
            }
            items.append(PippipTextMessageModel(textMessage: textMessage))
        }
        else {
            print("Duplicate messageId \(textMessage.messageId)")
        }
        
    }
    
    func addTextMessages(_ textMessages: [TextMessage]) {

        for textMessage in textMessages {
            addTextMessage(textMessage)
        }

    }

    func canSlideDown() -> Bool {
        
        return windowPos < messageList.count - windowSize
        
    }
    
    func canSlideUp() -> Bool {
        
        return windowPos > 0
        
    }
    
    func clearMessages() {

        messageList.removeAll()
        messageMap.removeAll()
        windowPos = 0
        items.removeAll()
        messageManager.clearMessages(contactId: contact.contactId)

    }

    func deleteMessage(_ messageId: Int64) {

        if let message = messageMap.removeValue(forKey: messageId) {
            if let index = messageList.index(of: message) {
                messageList.remove(at: index)
                items.remove(at: index - windowPos)
            }
            messageManager.deleteMessage(messageId: messageId)
        }

    }

    func filterMessages(_ textMessages: [TextMessage]) -> [TextMessage] {
        
        var filtered = [TextMessage]()
        for textMessage in textMessages {
            if textMessage.contactId == contact.contactId {
                filtered.append(textMessage)
            }
        }
        return filtered
        
    }
    
    func findMessageText(_ fragment: String) -> TextMessage? {
        
        for textMessage in messageList {
            if let _ = textMessage.cleartext?.uppercased().range(of: fragment.uppercased()) {
                return textMessage
            }
        }
        return nil
        
    }
    
    func getMessage(messageId: Int64) -> TextMessage? {

        return messageMap[messageId]

    }

    func loadInitialMessages() {

        let messages = messageManager.mostRecentMessages(contactId: contact.contactId, count: windowSize)
        for textMessage in messages {
            messageMap[textMessage.messageId] = textMessage
            messageList.insert(textMessage)
            if textMessage.ciphertext!.count < 25 {
                textMessage.decrypt(notify: false)
            }
            else {
                DispatchQueue.global().async {
                    textMessage.decrypt(notify: true)
                }
            }
            items.append(PippipTextMessageModel(textMessage: textMessage))
        }
//        for textMessage in messageList {
//            if textMessage.ciphertext!.count < 25 {
//                textMessage.decrypt(notify: false)
//            }
//            else {
//                DispatchQueue.global().async {
//                    textMessage.decrypt(notify: true)
//                }
//            }
//            items.append(PippipTextMessageModel(textMessage: textMessage))
//        }
        windowPos = max(0, messageManager.messageCount(contactId: contact.contactId) - windowSize)

    }

    func loadPreviousMessages() {

        if windowPos > 0 {
            let count = min(windowSize, messageManager.messageCount(contactId: contact.contactId) - messageList.count)
            windowPos = max(0, windowPos-windowSize)
            let messages = messageManager.getTextMessages(contactId: contact.contactId, pos: windowPos, count: count)
            for message in messages {
                messageMap[message.messageId] = message
                messageList.insert(message)
            }
            items.removeAll()
            for textMessage in messages {
                var deferred = [TextMessage]()
                if textMessage.ciphertext!.count < 25 {
                    textMessage.decrypt(notify: false)
                }
                else {
                    deferred.append(textMessage)
                }
                DispatchQueue.global().async {
                    for message in deferred {
                        message.decrypt(notify: true)
                    }
                }
            }
            for textMessage in messageList {
                items.append(PippipTextMessageModel(textMessage: textMessage))
            }
        }

    }

    func markAllMessagesRead() {

        if visible {
            DispatchQueue.global().async {
                for message in self.messageList {
                    if !message.read {
                        message.read = true
                        self.messageManager.markMessageRead(messageId: message.messageId)
                    }
                }
            }
        }

    }

    func messageFailed(_ messageId: Int64) {

        guard let message = messageMap[messageId] else { return }
        message.failed = true
        messageManager.updateMessage(message)
        for index in 0..<items.count {
            if items[index].message.messageId == messageId {
                items[index] = PippipTextMessageModel(textMessage: message)
            }
        }
        
    }

    func messageSent(messageId: Int64) {

        guard let message = messageMap[messageId] else { return }
        for index in 0..<items.count {
            if items[index].message.messageId == messageId {
                items[index] = PippipTextMessageModel(textMessage: message)
            }
        }
        
    }

    func retryTextMessage(_ textMessage: TextMessage) {

        guard let textMessage = messageMap[textMessage.messageId] else { return }
        textMessage.failed = false
        for index in 0..<items.count {
            if items[index].message.messageId == textMessage.messageId {
                items[index] = PippipTextMessageModel(textMessage: textMessage)
            }
        }
        messageManager.updateMessage(textMessage)
        messageManager.sendMessage(textMessage: textMessage, retry: true)

    }

    func searchMessages(_ fragment: String) -> Bool {
        
        for textMessage in messageList {
            if let _ = textMessage.cleartext?.uppercased().range(of: fragment.uppercased()) {
                return true
            }
        }
        return false
        
    }

    func slideDown() {
        
        if canSlideDown() {
            windowPos = min(windowPos + windowSize, windowPos + (messageList.count - windowSize))
            //markMessagesRead(messages: window)
        }
        
    }
    
    func slideUp() {
        
        if canSlideUp() {
            loadPreviousMessages()
        }
        
    }
    
    func updateAllChatItems() {

        items.removeAll()
        for message in messageList {
            if (message.cleartext != nil) {
                items.append(PippipTextMessageModel(textMessage: message))
            }
        }

    }

    func updateChatItem(textMessage: TextMessage) {
        
        if visible {
            if let index = messageList.anyIndex(of: textMessage) {
                items[index] = PippipTextMessageModel(textMessage: textMessage)
            }
            else {
                print("Message not found in updateChatItem")
            }
        }

    }

}
