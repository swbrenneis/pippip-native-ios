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
    private var mostRecent: TextMessage?
    private var pos: Int = Int.max
    private var newMessages: Int
    var messageCount: Int {
        get {
            return messageList.count
        }
    }

    init(_ contact: Contact) {

        self.contact = contact
        messageManager = MessageManager()
        newMessages = 0

        super.init()

    }

    func acknowledgeMessage(_ message: Message) {

        messageMap[message.messageId]?.acknowledged = true;

    }

    /*
     * Incoming text messages
     */
    func addTextMessages(_ textMessages: [TextMessage]) {

        for textMessage in textMessages {
            if messageMap[textMessage.messageId] == nil {
                messageList.insert(textMessage)
                messageMap[textMessage.messageId] = textMessage
                // Duplicate timestamps mess with the collection view
                while timestampSet.contains(textMessage.timestamp) {
                    textMessage.timestamp += 1
                }
                timestampSet.insert(textMessage.timestamp)
                if mostRecent == nil {
                    mostRecent = textMessage
                }
                else if textMessage.timestamp > mostRecent!.timestamp {
                    mostRecent = textMessage
                }
                if !textMessage.originating {
                    newMessages += 1
                }
            }
            else {
                print("Duplicate messageId \(textMessage.messageId)")
            }
        }

    }

    func clearMessages() {

        messageList.removeAll()
        messageMap.removeAll()
        timestampSet.removeAll()
        mostRecent = nil
        messageManager.clearMessages(contact.contactId)

    }

    func deleteMessage(_ messageId: Int64) {

        if let message = messageMap.removeValue(forKey: messageId) {
            timestampSet.remove(message.timestamp)
            if let index = messageList.index(of: message) {
                messageList.remove(at: index)
            }
            if message.messageId == mostRecent?.messageId {
                mostRecent = nil
            }
            messageManager.deleteMessage(messageId)
        }

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

        assert(pos < messageList.count || (pos == 0 && messageList.count == 0))
        let actualCount = min(messageList.count, pos + count)
        var subrange = [TextMessage]()
        for index in pos..<actualCount {
            subrange.append(messageList[index])
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
                // Most recent message may be a different instance.
                if mostRecent?.messageId == message.messageId {
                    mostRecent?.read = true
                }
                messageManager.markMessageRead(message.messageId)
            }
        }
    
    }

    @objc func mostRecentMessage() -> TextMessage? {

        if messageList.isEmpty {
            if let textMessage = messageManager.mostRecentMessage(contact.contactId) {
                messageList.insert(textMessage)
                messageMap[textMessage.messageId] = textMessage
            }
        }
        return messageList.last

    }

    // Resets new message count
    func newMessageCount() -> Int {

        let newCount = newMessages
        newMessages = 0
        return newCount

    }

    func sendMessage(_ textMessage: TextMessage) throws {

        textMessage.read = true
        let messageId = try messageManager.sendMessage(textMessage, retry: false)
        messageList.insert(textMessage)
        messageMap[messageId] = textMessage
        mostRecent = textMessage

    }
/*
    func setMessageTimestamp(_ messageId: Int64, timestamp: Int64) -> Int64 {

        var time = timestamp
        while timestampSet.contains(time) {
            time += 1
        }
        timestampSet.insert(time)
        let message = messageMap[messageId]!
        message.timestamp = time
        // Check timestamp in list
        return time

    }
*/
}
