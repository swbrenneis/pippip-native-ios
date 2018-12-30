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

    var config = Configurator()

    func acknowledgeMessages(_ textMessages: [TextMessage]) {

        var triplets = [Triplet]()
        for textMessage in textMessages {
            if (textMessage.contactId != NSNotFound) {
                if let contact = ContactsModel.instance.getContact(contactId: textMessage.contactId),
                    let publicId = contact.publicId {
                    let triplet = Triplet(publicId: publicId, sequence: Int(textMessage.sequence),
                                          timestamp: Int(textMessage.timestamp))
                    triplets.append(triplet)
                }
                else {
                    DDLogError("Message consistency error, contact ID invalid or contact public ID missing")
                }
            }
            else {
                DDLogError("Invalid message. Contact ID missing")
            }
        }

        let request = AcknowledgeMessagesRequest(messages: triplets)
        let delegate = AcknowledgeMessagesDelegate(request: request, textMessages: textMessages)
        let messageTask = EnclaveTask<AcknowledgeMessagesRequest, AcknowledgeMessagesResponse>(delegate: delegate)
        messageTask.errorTitle = "Message Error"
        messageTask.sendRequest(request)

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

    func getMessageCount(contactId: Int) -> Int {

        let realm = try! Realm()
        let messages = realm.objects(DatabaseMessage.self).filter("contactId = %ld", contactId)
        return messages.count

    }

    func getNewMessages() {

        let request = GetMessagesRequest()
        let delegate = GetMessagesDelegate(request: request)
        let messageTask = EnclaveTask<GetMessagesRequest, GetMessagesResponse>(delegate: delegate)
        messageTask.errorTitle = "Message Error"
        messageTask.sendRequest(request)

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

    func sendMessage(textMessage: TextMessage, retry: Bool) throws {

        if (!retry) {
            MessagesModel.instance.addTextMessages([textMessage])
        }

        guard let contact = ContactsModel.instance.getContact(contactId: textMessage.contactId) else {
            throw MessageError.invalidContactId
        }
        guard let publicId = contact.publicId else {
            throw ContactError.invalidPublicId
        }
        let request = SendMessageRequest(message: textMessage.encodeForServer(publicId: publicId))
        let delegate = SendMessageDelegate(request: request, textMessage: textMessage)
        let enclaveTask = EnclaveTask<SendMessageRequest, SendMessageResponse>(delegate: delegate)
        enclaveTask.errorTitle = "Message Error"
        enclaveTask.sendRequest(request)

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
