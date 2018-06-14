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
    var messageManager: MessageManager
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
    private var timestampSet = Set<Int64>()
    private var pos: Int = Int.max

    var messageCount: Int {
        return messageManager.getMessageCount(contactId: contact.contactId)
    }

    init(_ contact: Contact) {

        self.contact = contact
        messageManager = MessageManager()

        super.init()

    }

    func acknowledgeMessage(_ message: Message) {

        messageMap[message.messageId]?.acknowledged = true;

    }

    func addTextMessage(_ textMessage: TextMessage) {
        
        if messageMap[textMessage.messageId] == nil {
            messageList.insert(textMessage)
            messageMap[textMessage.messageId] = textMessage
        }
        else {
            print("Duplicate messageId \(textMessage.messageId)")
        }
        
    }

    func clearMessages() {

        messageList.removeAll()
        messageMap.removeAll()
        timestampSet.removeAll()
        messageManager.clearMessages(contactId: contact.contactId)

    }

    func deleteMessage(_ messageId: Int64) {

        if let message = messageMap.removeValue(forKey: messageId) {
            timestampSet.remove(message.timestamp)
            if let index = messageList.index(of: message) {
                messageList.remove(at: index)
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

    // Lazy loading of message list.
    func getMessages(pos: Int, count: Int) -> [TextMessage] {

        if pos < self.pos {
            // Returns a sorted list. Return maximum of messages remaining in database or count.
            let messages = messageManager.getTextMessages(contactId: contact.contactId,
                                                          pos: pos, count: count)
            self.pos = pos
            if !messages.isEmpty {
                for message in messages {
                    if messageMap[message.messageId] == nil {
                        messageMap[message.messageId] = message
                        messageList.insert(message)
                    }
                }
            }
        }

        let actualPos = min(pos, pos - self.pos)
        let actualCount = min(count, messageList.count)
        assert(actualPos + actualCount <= messageList.count)
        var subrange = [TextMessage]()
        for index in 0..<actualCount {
            subrange.append(messageList[index + actualPos])
        }
        return subrange
        
    }

    /*
     * Returns a temporary timestamp for sorting purposes
     */
    func getTimestamp() -> Int64 {

        var timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        while timestampSet.contains(timestamp) {
            timestamp += 1
        }
        return timestamp

    }

    func markMessagesRead(_ messages: [Message]) {

        for message in messages {
            if !message.read {
                message.read = true
                messageManager.markMessageRead(messageId: message.messageId)
            }
        }
    
    }

    func messageFailed(_ messageId: Int64) {

        guard let message = messageMap[messageId] else { return }
        message.failed = true
        messageManager.updateMessage(message)

    }

    func mostRecentMessage() -> TextMessage? {

        if messageList.isEmpty {
            if let textMessage = messageManager.mostRecentMessage(contactId: contact.contactId) {
                messageList.insert(textMessage)
                messageMap[textMessage.messageId] = textMessage
            }
        }
        return messageList.last

    }

    func retryTextMessage(_ messageId: Int64) {

        guard let textMessage = messageMap[messageId] else { return }
        textMessage.failed = false
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
/*
    func sendMessage(_ textMessage: TextMessage) throws {

        textMessage.read = true
        try textMessage.encrypt()
        textMessage.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        messageManager.sendMessage(textMessage: textMessage, retry: false)

    }
*/
}
