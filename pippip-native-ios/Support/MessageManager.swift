//
//  MessageManager.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/5/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

@objc class MessageManager: NSObject {

    var messageDatabase = MessagesDatabase()
    var contactManager = ContactManager()

    func getMessageIds(_ contactId: Int) -> [Int64] {

        var messageIds = [Int64]()
        let ids = messageDatabase.loadMessageIds(contactId)
        for id in ids {
            messageIds.append(id.int64Value)
        }
        return messageIds

    }

    @objc func getNewMessages() {

        var request = [AnyHashable: Any]()
        request["method"] = "GetMessages"
        let messageTask = EnclaveTask({ (response: [AnyHashable: Any]) -> Void in
            if let messages = response["messages"] as? [[AnyHashable: Any]] {
                if messages.count > 0 {
                    var textMessages = [TextMessage]()
                    for message in messages {
                        textMessages.append(TextMessage(serverMessage: message))
                    }
                    AsyncNotifier.notify(name: Notifications.NewMessages, object: textMessages)
                }
            }
        })
        messageTask.sendRequest(request)

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

    func sendMessage(_ message: TextMessage, retry: Bool) {

        let enclaveTask = EnclaveTask({ (response: [AnyHashable: Any]) -> Void in
            if let ts = response["timestamp"] as? NSNumber {
                message.timestamp = ts.int64Value
                self.messageDatabase.updateTimestamp(Int(message.messageId), withTimestamp: Int(message.timestamp))
                AsyncNotifier.notify(name: Notifications.MessageSent, object: message)
            }
        })
        let contact = contactManager.getContact(message.publicId)
        var request = message.encodeForServer(contact!)
        request["method"] = "SendMessage"
        enclaveTask.sendRequest(request)

        if (!retry) {
            messageDatabase.add(message)
        }

    }

}
