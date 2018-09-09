//
//  ConversationCache.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ConversationCache: NSObject {

    private static var conversations = [Int: Conversation]()
    
    static func getConversation(_ contactId: Int) -> Conversation {

        if let conversation = ConversationCache.conversations[contactId] {
            return conversation
        }
        else {
            let contactManager = ContactManager()
            let contact = contactManager.getContact(contactId: contactId)!
            let newConversation = Conversation(contact: contact, windowSize: 15)
            ConversationCache.conversations[contactId] = newConversation
            return newConversation
        }

    }

    @objc static func clearCache() {

        ConversationCache.conversations.removeAll()

    }

    static func newMessages(_ textMessages: [TextMessage]) {

        for textMessage in textMessages {
            if let conversation = ConversationCache.conversations[textMessage.contactId] {
                conversation.addTextMessage(textMessage)
            }
            else {
                print("Invalid contact ID \(textMessage.contactId)")
            }
        }

    }

    static func searchConversations(_ fragment: String) -> [Conversation] {

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
