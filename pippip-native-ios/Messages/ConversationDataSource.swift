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

    }
/*
 public init(currentUserID: String? = nil,
 nodeMetadataFactory: MessageCellNodeMetadataFactory = MessageCellNodeMetadataFactory(),
 bubbleImageProvider: MessageBubbleImageProvider = MessageBubbleImageProvider(),
 timestampFormatter: MessageTimestampFormatter = MessageTimestampFormatter(),
 bubbleNodeFactories: [MessageDataContentType: MessageBubbleNodeFactory] = [
 kAMMessageDataContentTypeText: MessageTextBubbleNodeFactory(),
 kAMMessageDataContentTypeNetworkImage: MessageNetworkImageBubbleNodeFactory()
 ]) {
 */
    func initialize() {
    }

    func loadMessages() {

        var messageData = [MessageData]()
        let textMessages = messageManager.getTextMessages(contact.contactId)
        for textMessage in textMessages {
            messageData.append(ConversationMessageData(textMessage))
        }
        if !messageData.isEmpty {
            self.collectionNode(collectionNode: asyncCollectionNode, insertMessages: messageData, completion: ({completion in
                NotificationCenter.default.post(name: Notifications.MessagesLoaded, object: nil)
            }))
        }

    }

    func appendMessage(_ textMessage: TextMessage) {
    
        self.collectionNode(collectionNode: asyncCollectionNode, insertMessages: [ConversationMessageData(textMessage)],
                            completion: nil)

    }

}
