//
//  ConversationCache.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

@objc class ConversationCache: NSObject {

    private static var conversations = [Int: Conversation]()
    
    @objc static func getConversation(_ contactId: Int) -> Conversation {

        if let conversation = ConversationCache.conversations[contactId] {
            return conversation
        }
        else {
            let contactManager = ContactManager()
            let contact = contactManager.getContactById(contactId)!
            let newConversation = Conversation(contact)
            ConversationCache.conversations[contactId] = newConversation
            return newConversation
        }

    }
    
}
