//
//  ConversationCache.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ConversationCache: NSObject {

    static var instance: ConversationCache {
        get {
            if let cache = ConversationCache.theInstance {
                return cache
            }
            else {
                ConversationCache.theInstance = ConversationCache()
                return ConversationCache.theInstance!
            }
        }
    }
    private static var theInstance: ConversationCache?
    private var conversations = [Int: Conversation]()
    
    private override init() {
        super.init()
    }

    func clearCache() {

        conversations.removeAll()

    }

    func deleteConversation(contactId: Int) {

        conversations[contactId]?.clearMessages()
        conversations.removeValue(forKey: contactId)
        AsyncNotifier.notify(name: Notifications.ConversationDeleted, object: contactId)
        
    }
    
    func getConversation(contactId: Int) -> Conversation {
        
        if let conversation = conversations[contactId] {
            return conversation
        }
        else {
            let contactManager = ContactManager.instance
            let contact = contactManager.getContact(contactId: contactId)!
            let newConversation = Conversation(contact: contact, windowSize: 15)
            conversations[contactId] = newConversation
            return newConversation
        }
        
    }
    
    func newMessages(textMessages: [TextMessage]) {

        for textMessage in textMessages {
            if let conversation = conversations[textMessage.contactId] {
                conversation.addTextMessage(textMessage)
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

}
