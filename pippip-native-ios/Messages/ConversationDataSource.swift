//
//  ConversationDataSource.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/4/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ConversationDataSource: DefaultAsyncMessagesCollectionViewDataSource {

    var messageManager = MessageManager()
    var contact: Contact
    var asyncCollectionNode: ASCollectionNode

    init(collectionNode: ASCollectionNode, contact: Contact) {

        self.asyncCollectionNode = collectionNode
        self.contact = contact

        super.init(currentUserID: contact.displayName, nodeMetadataFactory: ConversationCellNodeMetadataFactory())

        NotificationCenter.default.addObserver(self, selector: #selector(cleartextAvailable(_:)),
                                               name: Notifications.CleartextAvailable, object: nil)

    }

    // Should be cleartext. Called from send button event
    func appendMessage(_ textMessage: TextMessage) {
    
        self.collectionNode(collectionNode: asyncCollectionNode,
                            insertMessages: [ConversationMessageData(textMessage, contact: contact)],
                            completion: nil)

    }

    // Notified by message decryption
    @objc func cleartextAvailable(_ notification: Notification) {

        if let textMessage = notification.object as? TextMessage {
            let messageData = ConversationMessageData(textMessage, contact: contact)
            DispatchQueue.main.async {
                self.collectionNode(collectionNode: self.asyncCollectionNode,
                                    insertMessages: [messageData], completion:nil)
            }
        }

    }

}
