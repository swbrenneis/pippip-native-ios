//
//  MessageManager.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/5/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import RealmSwift

@objc class MessageManager: NSObject {

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

        let realm = try! Realm()
        try! realm.write {
            for textMessage in textMessages {
                realm.add(textMessage.encodeForDatabase())
            }
        }

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
/*
    func allMessages() -> [TextMessage] {
    }
*/
    func clearMessages(_ contactId: Int32) {

        let realm = try! Realm()
        let messages = realm.objects(DatabaseMessage.self).filter("contactId == %d", contactId)
        if !messages.isEmpty {
            try! realm.write {
                realm.delete(messages)
            }
        }

    }
    
    func decryptAll() {

        let realm = try! Realm()
        let messages = realm.objects(DatabaseMessage.self)
        for dbMessage in messages {
            let textMessage = TextMessage(dbMessage: dbMessage)
            textMessage.decrypt(noNotify: true)   // No notification
            try! realm.write {
                dbMessage.cleartext = textMessage.cleartext
            }
        }

    }

    func deleteMessage(_ messageId: Int64) {

        let realm = try! Realm()
        if let dbMessage = realm.objects(DatabaseMessage.self).filter("messageId == %lld", messageId).first {
            try! realm.write {
                realm.delete(dbMessage)
            }
        }
        
    }

    func getMessageCount(_ contactId: Int32) -> Int {

        let realm = try! Realm()
        let messages = realm.objects(DatabaseMessage.self).filter("contactId == %ld", contactId)
        return messages.count

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
                                if let textMessage = TextMessage(serverMessage: message) {
                                    textMessages.append(textMessage)
                                }
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

    func getTextMessages(contactId: Int32, pos: Int, count: Int) -> [TextMessage] {

        var textMessages = [TextMessage]()
        let realm = try! Realm()
        let messages = realm.objects(DatabaseMessage.self).filter("contactId = %d", contactId)
        for index in pos..<messages.count {
            textMessages.append(TextMessage(dbMessage: messages[index]))
        }
        return textMessages

    }

    func markMessageRead(_ messageId: Int64) {

        let realm = try! Realm()
        if let dbMessage = realm.objects(DatabaseMessage.self).filter("messageId == %lld", messageId).first {
            try! realm.write {
                dbMessage.read = true
            }
        }

    }

    func mostRecentMessage(_ contactId: Int32) -> TextMessage? {

        let realm = try! Realm()
        let message = realm.objects(DatabaseMessage.self).filter("contactId = %d", contactId)
                                                            .sorted(byKeyPath: "timestamp", ascending: true)
                                                            .last
        guard let _ = message else { return nil }
        return TextMessage(dbMessage: message!)

    }

    func scrubCleartext() {

        let realm = try! Realm()
        let messages = realm.objects(DatabaseMessage.self)
        try! realm.write {
            for dbMessage in messages {
                dbMessage.cleartext = nil
            }
        }
        
    }

    @discardableResult
    func sendMessage(_ textMessage: TextMessage, retry: Bool) throws -> Int64 {

        if (!retry) {
            try textMessage.encrypt()
            textMessage.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
            textMessage.messageId = config.newMessageId()
            addTextMessages([textMessage])
        }
        let messageId = textMessage.messageId

        let enclaveTask = EnclaveTask({ (response: [AnyHashable: Any]) -> Void in
            if let ts = response["timestamp"] as? NSNumber {
                textMessage.timestamp = ts.int64Value
                textMessage.acknowledged = true
                self.updateMessage(textMessage)
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

        let realm = try! Realm()
        if let dbMessage = realm.objects(DatabaseMessage.self).filter("messageId == %lld", message.messageId).first {
            try! realm.write {
                dbMessage.acknowledged = message.acknowledged
                dbMessage.timestamp = message.timestamp
                dbMessage.read = message.read
            }
        }

    }

}
