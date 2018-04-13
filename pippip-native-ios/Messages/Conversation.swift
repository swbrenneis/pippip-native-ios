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
                messageManager.decryptAll()
            }
        }
    }
    private var messageList = [TextMessage]()
    private var messageMap = [Int64: TextMessage]()
    private var timestampSet = Set<Int64>()

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

    func deleteMessage(_ messageId: Int64) {

        if let message = messageMap.removeValue(forKey: messageId) {
            timestampSet.remove(message.timestamp)
            if let index = messageList.index(of: message) {
                messageList.remove(at: index)
            }
            messageManager.deleteMessage(messageId)
        }

    }
/*
    func getMessage(_ messageId: Int64) -> TextMessage? {
        return messageMap[messageId]
    }

    func getMessageList() -> [TextMessage] {
        return messageList
    }

    func loadMessages() {

        messageList = messageManager.getTextMessages(contact.contactId)
        for message in messageList {
            timestampSet.insert(message.timestamp)
            messageMap[message.messageId] = message
        }

        DispatchQueue.global().async {
            for message in self.messageList {
                message.decrypt()
            }
        }

    }
*/
    func sendMessage(_ textMessage: TextMessage) throws {

        // Placeholder timestamp
        var timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        while timestampSet.contains(timestamp) {
            timestamp += 1
        }
        textMessage.timestamp = timestamp
        let messageId = try messageManager.sendMessage(textMessage, retry: false)
        messageList.append(textMessage)
        messageMap[messageId] = textMessage

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
