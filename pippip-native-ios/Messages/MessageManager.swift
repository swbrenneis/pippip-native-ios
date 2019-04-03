//
//  MessageManager.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/5/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import RealmSwift
import CocoaLumberjack
import AudioToolbox

class MessageManager: NSObject {

    static var sendSoundId: SystemSoundID = 0

    var contactManager = ContactManager()
    var config = Configurator()

    func acknowledgeMessages(_ textMessages: [TextMessage]) {

        var triplets = [Triplet]()
        for textMessage in textMessages {
            if (textMessage.contactId != NSNotFound) {
                let contact = ContactsModel.instance.getContact(contactId: textMessage.contactId)!
                let triplet = Triplet(publicId: contact.publicId, sequence: Int(textMessage.sequence),
                                      timestamp: Int(textMessage.timestamp))
                triplets.append(triplet)
            }
            else {
                print("Contact for ID \(textMessage.contactId) not found")
            }
        }

        let request = AcknowledgeMessagesRequest(messages: triplets)
        let messageTask = EnclaveTask<AcknowledgeMessagesRequest, AcknowledgeMessagesResponse>()
        messageTask.sendRequest(request: request)
            .then({ response in
                AsyncNotifier.notify(name: Notifications.GetMessagesComplete, object: nil)
                print("Messages acknowledged, \(response.exceptions!.count) exceptions")
                for textMessage in textMessages {
                    textMessage.acknowledged = true
                    MessagesModel.instance.updateMessage(textMessage)
                }
                MessagesModel.instance.newMessages(textMessages: textMessages)
                NotificationCenter.default.post(name: Notifications.NewMessages, object: textMessages)
            })
            .catch({ error in
                AsyncNotifier.notify(name: Notifications.GetMessagesComplete, object: nil)
                DDLogError("Acknowledge messages error: \(error.localizedDescription)")
            })

    }
/*
    func allTextMessages() -> [TextMessage] {
        
        var allMessages = [TextMessage]()
        let realm = try! Realm()
        let dbMessages = realm.objects(DatabaseMessage.self)
        for dbMessage in dbMessages {
            allMessages.append(TextMessage(dbMessage: dbMessage))
        }
        return allMessages

    }
*/
    func getNewMessages() {

        let messageTask = EnclaveTask<GetMessagesRequest, GetMessagesResponse>()
        messageTask.sendRequest(request: GetMessagesRequest())
        .then({ response in
            if response.messages!.count == 0 {
                // If non-zero, we have to acknowledge the messages before we move on to
                // pending requests
                AsyncNotifier.notify(name: Notifications.GetMessagesComplete, object: nil)
            }
            DDLogInfo("\(response.messages!.count) new messages returned")
            var textMessages = [TextMessage]()
            for message in response.messages! {
                if let textMessage = TextMessage(serverMessage: message) {
                    textMessages.append(textMessage)
                    try! ContactsModel.instance.updateTimestamp(contactId: textMessage.contactId, timestamp: textMessage.timestamp)
                }
                else {
                    DDLogWarn("Invalid contact information in server message")
                }
            }
            if !textMessages.isEmpty {
                MessagesModel.instance.addTextMessages(textMessages)
                self.acknowledgeMessages(textMessages)
            }
        })
        .catch({ error in
            NotificationCenter.default.post(name: Notifications.GetMessagesComplete, object: nil)
            DDLogError("Get messages error: \(error.localizedDescription)")
        })

    }

    func sendMessage(textMessage: TextMessage, retry: Bool) {

        if (!retry) {
            MessagesModel.instance.addTextMessages([textMessage])
        }

        let contact = ContactsModel.instance.getContact(contactId: textMessage.contactId)!
        let request = SendMessageRequest(message: textMessage.encodeForServer(publicId: contact.publicId))
        let enclaveTask = EnclaveTask<SendMessageRequest, SendMessageResponse>()
        enclaveTask.sendRequest(request: request)
            .then({ response in                
                textMessage.timestamp = Int64(response.timestamp!)
                textMessage.acknowledged = true
                MessagesModel.instance.updateMessage(textMessage)
                DispatchQueue.main.async {
                    AudioServicesPlaySystemSound(MessageManager.sendSoundId)
                    NotificationCenter.default.post(name: Notifications.MessageSent, object: textMessage.messageId)
                }
                do {
                    try ContactsModel.instance.updateTimestamp(contactId: textMessage.contactId,
                                                               timestamp: textMessage.timestamp)
                }
                catch {
                    DDLogError("Error updating contact timestamp: \(error.localizedDescription)")
                }
                
            })
            .catch({ error in
                DDLogError("Send message error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notifications.MessageFailed, object: textMessage)
                }
            })

    }

}
