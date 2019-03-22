//
//  MessageManager.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/5/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import RealmSwift
import CocoaLumberjack

class MessageManager: NSObject {

    var contactManager = ContactManager()
    var config = Configurator()
    var alertPresenter = AlertPresenter()

    func acknowledgeMessages(_ textMessages: [TextMessage]) {

        var triplets = [Triplet]()
        for textMessage in textMessages {
            if (textMessage.contactId != NSNotFound) {
                let contact = ContactsModel.instance.getContact(contactId: textMessage.contactId)!
                let triplet = Triplet(publicId: contact.publicId, sequence: Int(textMessage.sequence),
                                      timestamp: Int(textMessage.timestamp))
                triplets.append(triplet)
            }
            else {
                print("Contact for ID \(textMessage.contactId) not found")
            }
        }

        let request = AcknowledgeMessagesRequest(messages: triplets)
//        let delegate = AcknowledgeMessagesDelegate(request: request, textMessages: textMessages)
        let messageTask = EnclaveTask<AcknowledgeMessagesRequest, AcknowledgeMessagesResponse>()
        messageTask.errorTitle = "Message Error"
        messageTask.sendRequest(request: request)

    }

    /*
     * Adds incoming messages to the database and to their conversations
     */
    func addTextMessages(_ textMessages: [TextMessage]) {

        let realm = try! Realm()
        for textMessage in textMessages {
            if getIdFromTuple(contactId: textMessage.contactId,
                              sequence: textMessage.sequence,
                              timestamp: textMessage.timestamp) == Int64(NSNotFound) {
                let dbMessage = textMessage.encodeForDatabase()
                dbMessage.messageId = config.newMessageId()
                textMessage.messageId = dbMessage.messageId
                try! realm.write {
                    realm.add(dbMessage)
                }
            }
            else {
                print("Duplicate message ID")
            }
        }

    }

    func allTextMessages() -> [TextMessage] {
        
        var allMessages = [TextMessage]()
        let realm = try! Realm()
        let dbMessages = realm.objects(DatabaseMessage.self)
        for dbMessage in dbMessages {
            allMessages.append(TextMessage(dbMessage: dbMessage))
        }
        return allMessages

    }

    func clearMessages(contactId: Int) {

        let realm = try! Realm()
        let messages = realm.objects(DatabaseMessage.self).filter("contactId = %ld", contactId)
        try! realm.write {
            realm.delete(messages)
        }
        
    }

    func deleteMessage(messageId: Int64) {

        let realm = try! Realm()
        if let dbMessage = realm.objects(DatabaseMessage.self).filter("messageId = %lld", messageId).first {
            try! realm.write {
                realm.delete(dbMessage)
            }
        }
        else {
            print("Message not found in database for deletion")
        }
        
    }

    func getIdFromTuple(contactId: Int, sequence: Int64, timestamp: Int64) -> Int64 {

        let realm = try! Realm()
        let format = "contactId = %ld AND sequence = %lld AND timestamp = %lld"
        if let dbMessage = realm.objects(DatabaseMessage.self).filter(format, contactId, sequence, timestamp).first {
            return dbMessage.messageId
        }
        else {
            return Int64(NSNotFound)

        }

    }
    
    func getMessageCount(contactId: Int) -> Int {

        let realm = try! Realm()
        let messages = realm.objects(DatabaseMessage.self).filter("contactId = %ld", contactId)
        return messages.count

    }

    func getNewMessages() {

        let messageTask = EnclaveTask<GetMessagesRequest, GetMessagesResponse>()
        messageTask.sendRequest(request: GetMessagesRequest())
        .then({ response in
            if response.messages!.count == 0 {
                // If non-zero, we have to acknowledge the messages before we move on to
                // pending requests
                AsyncNotifier.notify(name: Notifications.GetMessagesComplete, object: nil)
            }
            DDLogInfo("\(response.messages!.count) new messages returned")
            var textMessages = [TextMessage]()
            for message in response.messages! {
                if let textMessage = TextMessage(serverMessage: message) {
                    textMessages.append(textMessage)
                    try! ContactsModel.instance.updateTimestamp(contactId: textMessage.contactId, timestamp: textMessage.timestamp)
                }
                else {
                    DDLogWarn("Invalid contact information in server message")
                }
            }
            if !textMessages.isEmpty {
                self.addTextMessages(textMessages)
                self.acknowledgeMessages(textMessages)
            }
        })
        .catch({ error in
            NotificationCenter.default.post(name: Notifications.GetMessagesComplete, object: nil)
            DDLogError("Get messages error: \(error.localizedDescription)")
        })

    }

    func getTextMessages(contactId: Int, pos: Int, count: Int) -> [TextMessage] {

        var textMessages = [TextMessage]()
        let realm = try! Realm()
        let dbMessages = realm.objects(DatabaseMessage.self)
                                .filter("contactId = %ld", contactId)
                                .sorted(byKeyPath: "timestamp", ascending: true)

        if pos >= dbMessages.count {
            return textMessages
        }
        let end = min(pos+count, dbMessages.count)
        for index in pos..<end {
            textMessages.append(TextMessage(dbMessage: dbMessages[index]))
        }

        return textMessages

    }

    func markMessageRead(messageId: Int64) {

        let realm = try! Realm()
        if let dbMessage = realm.objects(DatabaseMessage.self).filter("messageId = %ld", messageId).first {
            try! realm.write {
                dbMessage.read = true
            }
        }

    }

    func messageCount(contactId: Int) -> Int {
        
        let realm = try! Realm()
        let dbMessages = realm.objects(DatabaseMessage.self).filter("contactId = %ld", contactId)
        return dbMessages.count

    }

    func mostRecentMessages(contactId: Int, count: Int) -> [TextMessage] {

        let realm = try! Realm()
        let dbMessages = realm.objects(DatabaseMessage.self)
                                .filter("contactId = %ld", contactId)
                                .sorted(byKeyPath: "timestamp", ascending: true)
        var messages = [TextMessage]()
        let pos = max(0, dbMessages.count - count)
        for index in pos..<dbMessages.count {
            messages.append(TextMessage(dbMessage: dbMessages[index]))
        }

        return messages

    }

    func sendMessage(textMessage: TextMessage, retry: Bool) {

        if (!retry) {
            addTextMessages([textMessage])
        }

        let contact = ContactsModel.instance.getContact(contactId: textMessage.contactId)!
        let request = SendMessageRequest(message: textMessage.encodeForServer(publicId: contact.publicId))
        //let delegate = SendMessageDelegate(request: request, textMessage: textMessage)
        let enclaveTask = EnclaveTask<SendMessageRequest, SendMessageResponse>()
        enclaveTask.errorTitle = "Message Error"
        enclaveTask.sendRequest(request: request)

    }

    func sendPendingMessage(message: String, recipient: String) {
        
        let request = SendPendingMessageRequest(recipient: recipient, message: message)
        let enclaveTask = EnclaveTask<SendPendingMessageRequest, SendPendingMessageResponse>()
        enclaveTask.sendRequest(request: request)
            .then({ response in
                if let error = response.error {
                    DDLogError("Error sending pending message: \(error)")
                } else {
                    guard let contact = ContactsModel.instance.getContact(publicId: recipient) else { return }
                    if contact.status == Contact.ACCEPTED {
                        let textMessage = TextMessage(text: message, contact: contact)
                        try! textMessage.encrypt()
                        let conversation = ConversationCache.instance.getConversation(contactId: contact.contactId)
                        conversation?.addTextMessage(textMessage, initial: true)
                    }
                }
            })
            .catch({ error in
                DDLogError("Error sending pending message: \(error.localizedDescription)")
            })
    
    }
    
    func updateMessage(_ message: Message) {

        let realm = try! Realm()
        if let dbMessage = realm.objects(DatabaseMessage.self).filter("messageId = %lld", message.messageId).first {
            try! realm.write {
                dbMessage.acknowledged = message.acknowledged
                dbMessage.read = message.read
                dbMessage.failed = message.failed
                dbMessage.timestamp = message.timestamp
            }
        }
        else {
            print("Message ID \(message.messageId) not found in database for update")
        }

    }

}
