//
//  MessagesModel.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/23/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import Foundation
import RealmSwift
import CocoaLumberjack

class MessagesModel {
    
    private static var theInstance: MessagesModel?
    
    static var instance: MessagesModel {
        if let model = MessagesModel.theInstance {
            return model
        } else {
            MessagesModel.theInstance = MessagesModel()
            return MessagesModel.theInstance!
        }
    }
    var config = Configurator()
    private var conversations = [Int: Conversation]()

    private init() {
        
    }
    
    /*
     * Adds incoming messages to the database
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
                DDLogError("Duplicate message ID")
            }
        }
        
    }
    
    func clearCache() {
        
        conversations.removeAll()
        
    }
    
    func clearMessages(contactId: Int) {
        
        let realm = try! Realm()
        let messages = realm.objects(DatabaseMessage.self).filter("contactId = %ld", contactId)
        try! realm.write {
            realm.delete(messages)
        }
        
    }
    
    func deleteConversation(contactId: Int) {
        
        conversations[contactId]?.clearMessages()
        conversations.removeValue(forKey: contactId)
        AsyncNotifier.notify(name: Notifications.ConversationDeleted, object: contactId)
        
    }
    
    func deleteMessage(messageId: Int64) {
        
        let realm = try! Realm()
        if let dbMessage = realm.objects(DatabaseMessage.self).filter("messageId = %lld", messageId).first {
            try! realm.write {
                realm.delete(dbMessage)
            }
        }
        else {
            DDLogError("Message not found in database for deletion")
        }

    }
    
    func getConversation(contactId: Int) -> Conversation? {
        
        if let conversation = conversations[contactId] {
            return conversation
        }
        else {
            guard let contact = ContactsModel.instance.getContact(contactId: contactId) else { return nil }
            let newConversation = Conversation(contact: contact, windowSize: 15)
            conversations[contactId] = newConversation
            return newConversation
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
    /*
    func getMessageCount(contactId: Int) -> Int {
        
        let realm = try! Realm()
        let messages = realm.objects(DatabaseMessage.self).filter("contactId = %ld", contactId)
        return messages.count
        
    }
    */
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
    
    func newMessages(textMessages: [TextMessage]) {
        
        for textMessage in textMessages {
            if let conversation = conversations[textMessage.contactId] {
                conversation.addTextMessage(textMessage, initial: false)
            }
            else {
                print("Invalid contact ID \(textMessage.contactId)")
            }
        }
        
    }
    
    func searchConversations(fragment: String) -> [Conversation] {
        
        var found = [Conversation]()
        for contactId in conversations.keys {
            let conversation = conversations[contactId]!
            if conversation.searchMessages(fragment) {
                found.append(conversation)
            }
        }
        return found
        
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
