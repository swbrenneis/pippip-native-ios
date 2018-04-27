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
    var isVisible = false {
        didSet {
            if isVisible {
                loadMessages()
            }
        }
    }
    private var messageList = [TextMessage]()
    private var messageMap = [Int64: TextMessage]()
    private var timestampSet = Set<Int64>()
    private var mostRecent: TextMessage?
    private var messagesLoaded = false

    init(_ contact: Contact) {

        self.contact = contact

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
                messageList.append(textMessage)
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
                if isVisible {
                    DispatchQueue.global().async {
                        textMessage.decrypt()
                    }
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
        messageManager.deleteMessages(contact.contactId)

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

    func markMessagesRead() {

        for message in messageList {
            if !message.read {
                message.read = true
                messageManager.markMessageRead(message.messageId)
            }
        }
    
    }

    @objc func mostRecentMessage() -> TextMessage? {

        if mostRecent == nil {
            mostRecent = messageManager.mostRecentMessage(contact.contactId)
        }
        return mostRecent

    }

    func loadMessages() {

        if !messagesLoaded {
            messagesLoaded = true
            messageList = messageManager.getTextMessages(contact.contactId)
            for message in messageList {
                timestampSet.insert(message.timestamp)
                messageMap[message.messageId] = message
                if mostRecent == nil {
                    mostRecent = message
                }
                else if message.timestamp > mostRecent!.timestamp {
                    mostRecent = message
                }
            }
        }

        DispatchQueue.global().async {
            for message in self.messageList {
                message.decrypt()
            }
        }

    }

    func sendMessage(_ textMessage: TextMessage) throws {

        let messageId = try messageManager.sendMessage(textMessage, retry: false)
        messageList.append(textMessage)
        messageMap[messageId] = textMessage
        if mostRecent == nil {
            mostRecent = textMessage
        }
        else if textMessage.timestamp > mostRecent!.timestamp {
            mostRecent = textMessage
        }

    }

    func setTimestamp(_ messageId: Int64, timestamp: Int64) -> Int64 {

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

}
