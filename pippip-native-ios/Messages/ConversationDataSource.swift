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

        super.init(currentUserID: contact.displayName,
                   nodeMetadataFactory: ConversationCellNodeMetadataFactory(),
                   bubbleImageProvider: MessageBubbleImageProvider(incomingColor: UIColor.flatWhiteDark,
                                                                   outgoingColor: UIColor.flatPowderBlueDark),
                   bubbleNodeFactories: [kAMMessageDataContentTypeText: MutableTextBubbleNodeFactory()])

//        NotificationCenter.default.addObserver(self, selector: #selector(cleartextAvailable(_:)),
//                                               name: Notifications.CleartextAvailable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(messagesReady(_:)),
                                               name: Notifications.MessagesReady, object: nil)

    }

    // Should be cleartext. Called from send button event
    func appendMessage(_ textMessage: TextMessage) {
    
        self.collectionNode(collectionNode: asyncCollectionNode,
                            insertMessages: [ConversationMessageData(textMessage, contact: contact)],
                            completion: nil)
        NotificationCenter.default.post(name: Notifications.MessageAdded, object: nil)

    }

    func clearMessages() {

        let rows = asyncCollectionNode.numberOfItems(inSection: 0)
        var paths = [IndexPath]()
        for item in 0..<rows {
            paths.append(IndexPath(row: item, section: 0))
        }
        self.collectionNode(collectionNode: asyncCollectionNode, deleteMessagesAtIndexPaths: paths, completion: nil)

    }

    // Notified by message decryption
    @objc func cleartextAvailable(_ notification: Notification) {

        guard let textMessage = notification.object as? TextMessage else { return }
        if textMessage.contactId == contact.contactId {
            var messageIndex = -1
            for index in 0..<messages.count {
                let messageData = messages[index] as! ConversationMessageData
                if messageData.messageId() == textMessage.messageId {
                    messageIndex = index
                }
            }
            assert(messageIndex >= 0)
            let deletePath = IndexPath(item: messageIndex, section: 0)
            let newData = ConversationMessageData(textMessage, contact: contact)
            DispatchQueue.main.async {
                self.collectionNode(collectionNode: self.asyncCollectionNode,
                                    deleteMessagesAtIndexPaths: [deletePath], completion: nil)
                self.collectionNode(collectionNode: self.asyncCollectionNode,
                                    insertMessages: [newData], completion:nil)
                NotificationCenter.default.post(name: Notifications.MessageAdded, object: nil)
            }
        }

    }

    @objc func messagesReady(_ notification: Notification) {

        if let messages = notification.object as? [TextMessage] {
            var messageData = [ConversationMessageData]()
            for message in messages {
                messageData.append(ConversationMessageData(message, contact: contact))
            }
            DispatchQueue.main.async {
                self.collectionNode(collectionNode: self.asyncCollectionNode,
                                    insertMessages: messageData, completion:nil)
                for textMessage in messages {
                    if textMessage.cleartext == nil {
                        DispatchQueue.global(qos: .background).async {
                            textMessage.decrypt()
                        }
                    }
                }
                NotificationCenter.default.post(name: Notifications.MessageAdded, object: nil)
            }
        }

    }

}
