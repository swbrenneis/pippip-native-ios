//
//  MessageManager.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/5/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

@objc class MessageManager: NSObject {

    var messageDatabase = MessagesDatabase()
    var contactManager = ContactManager()
    var config = Configurator()

    func acknowledgeMessages(_ textMessages:[TextMessage]) {

        var serverMessages = [[AnyHashable: Any]]()
        for textMessage in textMessages {
            if (textMessage.contactId != NSNotFound) {
                let contact = contactManager.getContactById(textMessage.contactId)!
                var tuple = [String: Any]()
                tuple["publicId"] = contact.publicId
                tuple["sequence"] = textMessage.sequence
                tuple["timestamp"] = textMessage.timestamp
                serverMessages.append(tuple)
            }
            else {
                print("Contact for ID \(textMessage.contactId) not found")
            }
        }
        var request = [AnyHashable: Any]()
        request["method"] = "AcknowledgeMessages"
        request["messages"] = serverMessages
        let messageTask = EnclaveTask({ (response: [AnyHashable: Any]) -> Void in
            if let exceptions = response["exceptions"] as? [[AnyHashable: Any]] {
                print("Messages acknowledged, \(exceptions.count) exceptions")
            }
            for textMessage in textMessages {
                textMessage.acknowledged = true
                /*
                if (textMessage.contactId != NSNotFound) {
                    let conversation = ConversationCache.getConversation(textMessage.contactId)
                    conversation.acknowledgeMessage(textMessage)
                    let message = self.messageDatabase.getMessage(Int(textMessage.messageId))
                    message.acknowledged = true
                    self.messageDatabase.update(message)
                }
 */
            }
            self.addTextMessages(textMessages)
            NotificationCenter.default.post(name: Notifications.NewMessages, object: nil)
        })
        messageTask.errorTitle = "Message Error"
        messageTask.sendRequest(request)

    }

    /*
     * Adds incoming messages to the database and to their conversations
     */
    private func addTextMessages(_ textMessages: [TextMessage]) {

        messageDatabase.add(textMessages)
        let ids = contactManager.allContactIds()
        for contactId in ids {
            var newMessages = [TextMessage]()
            for textMessage in textMessages {
                if textMessage.contactId == contactId {
                    newMessages.append(textMessage)
                }
            }
            if !newMessages.isEmpty {
                ConversationCache.getConversation(contactId).addTextMessages(newMessages)
            }
        }
        
    }

    @objc func allMessages() -> [TextMessage] {
        return messageDatabase.allTextMessages()
    }

    func decryptAll() {

        let messageIds = messageDatabase.allMessageIds();
        for messageId in messageIds {
            let textMessage = messageDatabase.getTextMessage(messageId.intValue)
            textMessage.decrypt(true)   // No notification
            messageDatabase.update(textMessage)
        }

    }

    func clearMessages(_ contactId: Int) {

        messageDatabase.clearMessages(contactId)

    }

    func deleteMessage(_ messageId: Int64) {
        
        messageDatabase.deleteMessage(Int(messageId))
        
    }

    func getMessageCount(_ contactId: Int) -> Int {

        return messageDatabase.getMessageCount(contactId)

    }

    @objc func getNewMessages() {

        var request = [AnyHashable: Any]()
        request["method"] = "GetMessages"
        let messageTask = EnclaveTask({ (response: [AnyHashable: Any]) -> Void in
            if let messages = response["messages"] as? [[AnyHashable: Any]] {
                print("\(messages.count) new messages returned")
                var textMessages = [TextMessage]()
                for message in messages {
                    if let publicId = message["fromId"] as? String {
                        if let contact = self.contactManager.getContact(publicId) {
                            if contact.status == "accepted" {
                                let textMessage = TextMessage(serverMessage: message)
                                textMessages.append(textMessage)
                            }
                        }
                    }
                }
                if !textMessages.isEmpty {
                    //self.addTextMessages(textMessages)
                    self.acknowledgeMessages(textMessages)
                }
            }
        })
        messageTask.errorTitle = "Message Error"
        messageTask.sendRequest(request)

    }

    func getTextMessages(contactId: Int, pos: Int, count: Int) -> [TextMessage] {

        return messageDatabase.getTextMessages(contactId, withPosition:pos, withCount:count)

    }

    func markMessageRead(_ messageId: Int64) {

        let message = messageDatabase.getMessage(Int(messageId))
        message.read = true
        messageDatabase.update(message)

    }

    func mostRecentMessage(_ contactId: Int) -> TextMessage? {

        return messageDatabase.mostRecentTextMessage(contactId);

    }
/*
    @objc func mostRecentMessages() -> [TextMessage] {

        var messages = [TextMessage]()
        let contactIds = contactManager.allContactIds()
        for contactId in contactIds {
            if let message = messageDatabase.mostRecentTextMessage(contactId) {
                messages.append(message)
            }
        }
        return messages

    }
*/
    func scrubCleartext() {
        
        let messageIds = messageDatabase.allMessageIds();
        for messageId in messageIds {
            let textMessage = messageDatabase.getTextMessage(messageId.intValue)
            textMessage.cleartext = nil
            messageDatabase.update(textMessage)
        }
        
    }

    @discardableResult
    func sendMessage(_ textMessage: TextMessage, retry: Bool) throws -> Int64 {

        if (!retry) {
            try textMessage.encrypt()
            textMessage.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
            messageDatabase.add(textMessage)
        }
        let messageId = textMessage.messageId

        let enclaveTask = EnclaveTask({ (response: [AnyHashable: Any]) -> Void in
            if let ts = response["timestamp"] as? NSNumber {
                textMessage.timestamp = ts.int64Value
                textMessage.acknowledged = true
                self.messageDatabase.update(textMessage)
            }
        })
        let contact = contactManager.getContactById(textMessage.contactId)
        var request = textMessage.encodeForServer(publicId: contact!.publicId)
        request["method"] = "SendMessage"
        enclaveTask.errorTitle = "Message Error"
        enclaveTask.sendRequest(request)
        return messageId

    }

    func updateMessage(_ message: Message) {

        messageDatabase.update(message)

    }

}
