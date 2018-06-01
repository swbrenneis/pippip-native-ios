//
//  MessageManager.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/5/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import AudioToolbox

@objc class MessageManager: NSObject {

    static var sendSoundId: SystemSoundID = 0
    static var receiveSoundId: SystemSoundID = 0
    static var initialized = false

    var messageDatabase = MessagesDatabase()
    var contactManager = ContactManager()
    var config = Configurator()

    override init() {

        if !MessageManager.initialized {
            MessageManager.initialized = true
            if let sendUrl = Bundle.main.url(forResource: "iphone_send_sms", withExtension: "mp3") {
                AudioServicesCreateSystemSoundID(sendUrl as CFURL, &MessageManager.sendSoundId)
            }
            if let receiveUrl = Bundle.main.url(forResource: "iphone_receive_sms", withExtension: "mp3") {
                AudioServicesCreateSystemSoundID(receiveUrl as CFURL, &MessageManager.receiveSoundId)
            }
        }
        
    }

    func acknowledgeMessages(_ textMessages:[TextMessage]) {

        var serverMessages = [[AnyHashable: Any]]()
        for textMessage in textMessages {
            if (textMessage.contactId != NSNotFound) {
                let contact = contactManager.getContactById(textMessage.contactId)!
                var tuple = [String: Any]()
                tuple["publicId"] = contact.publicId
                tuple["sequence"] = textMessage.sequence
                tuple["timestamp"] = textMessage.timestamp
                serverMessages.append(tuple)
            }
            else {
                print("Contact for ID \(textMessage.contactId) not found")
            }
        }
        var request = [String: Any]()
        request["method"] = "AcknowledgeMessages"
        request["messages"] = serverMessages
        let messageTask = EnclaveTask({ (response: [AnyHashable: Any]) -> Void in
            if let exceptions = response["exceptions"] as? [[AnyHashable: Any]] {
                print("Messages acknowledged, \(exceptions.count) exceptions")
            }
            for textMessage in textMessages {
                textMessage.acknowledged = true
            }
            self.addTextMessages(textMessages)
            NotificationCenter.default.post(name: Notifications.NewMessages, object: textMessages)
        })
        messageTask.errorTitle = "Message Error"
        messageTask.sendRequest(request)

    }

    /*
     * Adds incoming messages to the database and to their conversations
     */
    private func addTextMessages(_ textMessages: [TextMessage]) {

        messageDatabase.add(textMessages)
        ConversationCache.newMessages(textMessages)

    }

    @objc func allMessages() -> [TextMessage] {
        return messageDatabase.allTextMessages()
    }

    func clearMessages(_ contactId: Int) {
        
        messageDatabase.clearMessages(contactId)
        
    }
    
    func decryptAll() {

        let messageIds = messageDatabase.allMessageIds();
        for messageId in messageIds {
            let textMessage = messageDatabase.getTextMessage(messageId.intValue)
            textMessage.decrypt(noNotify: true)   // No notification
            messageDatabase.updateCleartext(textMessage)
        }

    }

    func deleteMessage(_ messageId: Int64) {
        
        messageDatabase.deleteMessage(Int(messageId))
        
    }

    func getMessageCount(_ contactId: Int) -> Int {

        return messageDatabase.getMessageCount(contactId)

    }

    @objc func getNewMessages() {

        var request = [String: Any]()
        request["method"] = "GetMessages"
        let messageTask = EnclaveTask({ (response: [AnyHashable: Any]) -> Void in
            if let messages = response["messages"] as? [[AnyHashable: Any]] {
                print("\(messages.count) new messages returned")
                var textMessages = [TextMessage]()
                for message in messages {
                    if let publicId = message["fromId"] as? String {
                        if let contact = self.contactManager.getContact(publicId) {
                            if contact.status == "accepted" {
                                let textMessage = TextMessage(serverMessage: message)
                                textMessages.append(textMessage)
                            }
                        }
                    }
                }
                if !textMessages.isEmpty {
                    self.acknowledgeMessages(textMessages)
                }
            }
        })
        messageTask.errorTitle = "Message Error"
        messageTask.sendRequest(request)

    }

    func getTextMessages(contactId: Int, pos: Int, count: Int) -> [TextMessage] {

        return messageDatabase.getTextMessages(contactId, withPosition:pos, withCount:count)

    }

    func markMessageRead(_ messageId: Int64) {

        let message = messageDatabase.getMessage(Int(messageId))
        message.read = true
        messageDatabase.update(message)

    }

    func mostRecentMessage(_ contactId: Int) -> TextMessage? {

        return messageDatabase.mostRecentTextMessage(contactId);

    }

    func scrubCleartext() {
        
        let messageIds = messageDatabase.allMessageIds();
        for messageId in messageIds {
            let textMessage = messageDatabase.getTextMessage(messageId.intValue)
            textMessage.cleartext = nil
            messageDatabase.scrubCleartext(textMessage)
        }
        
    }

    @discardableResult
    func sendMessage(_ textMessage: TextMessage, retry: Bool) throws -> Int64 {

        if (!retry) {
            try textMessage.encrypt()
            textMessage.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
            messageDatabase.add(textMessage)
        }
        let messageId = textMessage.messageId

        let enclaveTask = EnclaveTask({ (response: [AnyHashable: Any]) -> Void in
            if let ts = response["timestamp"] as? NSNumber {
                textMessage.timestamp = ts.int64Value
                textMessage.acknowledged = true
                self.messageDatabase.update(textMessage)
                DispatchQueue.main.async {
                    AudioServicesPlaySystemSound(MessageManager.sendSoundId)
                    NotificationCenter.default.post(name: Notifications.MessageSent, object: textMessage.messageId,
                                                    userInfo: nil)
                }
            }
        })
        let contact = contactManager.getContactById(textMessage.contactId)
        var request = textMessage.encodeForServer(publicId: contact!.publicId)
        request["method"] = "SendMessage"
        enclaveTask.errorTitle = "Message Error"
        enclaveTask.sendRequest(request)
        return messageId

    }

    func updateMessage(_ message: Message) {

        messageDatabase.update(message)

    }

}
