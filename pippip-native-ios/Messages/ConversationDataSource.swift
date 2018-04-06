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

    var publicId = ""
    var messageManager = MessageManager()
    var contact: Contact?

    func loadMessages(contact: Contact, asyncCollectionNode: ASCollectionNode) {

        self.contact = contact
        self.publicId = contact.publicId
        
//        let textMessages = getTextMessages()
        var messageData = [MessageData]()
        let textMessages = messageManager.getTextMessages(contact.contactId)
        for textMessage in textMessages {
            messageData.append(ConversationMessageData(message: textMessage))
        }
        if !messageData.isEmpty {
            self.collectionNode(collectionNode: asyncCollectionNode, insertMessages: messageData, completion: ({completion in
                NotificationCenter.default.post(name: Notifications.MessagesLoaded, object: nil)
            }))
        }

    }
/*
    func getTextMessages() -> [TextMessage] {

        var textMessages = [TextMessage]()
        let messageIds = messageManager.getMessageIds(contact!.publicId)
        for mid in messageIds {
            let textMessage = messageManager.getTextMessage(mid.intValue, withContactId: contact!.contactId)
            textMessages.append(textMessage)
        }
        
        return textMessages

    }
*/
}
