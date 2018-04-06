//
//  MessageManager.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/5/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

@objc class MessageManager: NSObject, RequestProcessProtocol {

    var postPacket: PostPacket?
    var errorDelegate: ErrorDelegate = NotificationErrorDelegate(title: "Message Error")

    func sessionComplete(_ response: [AnyHashable : Any]) {
        
    }

    func postComplete(_ response: [AnyHashable : Any]) {
        
    }

    var messageDatabase = MessagesDatabase()

    func getMessageIds(_ contactId: Int) -> [Int64] {

        var messageIds = [Int64]()
        let ids = messageDatabase.loadMessageIds(contactId)
        for id in ids {
            messageIds.append(id.int64Value)
        }
        return messageIds

    }

    @objc func getNewMessages() {
        
    }

    func getTextMessages(_ contactId: Int) -> [TextMessage] {

        let messageIds = getMessageIds(contactId)
        var messages = [TextMessage]()
        for messageId in messageIds {
            let message = messageDatabase.loadTextMessage(Int(messageId), withContactId: contactId)
            messages.append(message)
        }
        return messages

    }

}
