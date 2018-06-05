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
    var alertPresenter = AlertPresenter()

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

        var triplets = [Triplet]()
        for textMessage in textMessages {
            if (textMessage.contactId != NSNotFound) {
                let contact = contactManager.getContactById(textMessage.contactId)!
                let triplet = Triplet(publicId: contact.publicId, sequence: Int(textMessage.sequence),
                                      timestamp: Int(textMessage.timestamp))
                triplets.append(triplet)
            }
            else {
                print("Contact for ID \(textMessage.contactId) not found")
            }
        }
        let request = AcknowledgeMessagesRequest(messages: triplets)
        let messageTask = EnclaveTask<AcknowledgeMessagesResponse>(
        { (response: AcknowledgeMessagesResponse) -> Void in
            print("Messages acknowledged, \(response.exceptions!.count) exceptions")
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

        let request = GetMessagesRequest()
        let messageTask = EnclaveTask<GetMessagesResponse>({ (response: GetMessagesResponse) -> Void in
            print("\(response.messages!.count) new messages returned")
            var textMessages = [TextMessage]()
            for message in response.messages! {
                if let contact = self.contactManager.getContact(message.fromId!) {
                    if contact.status == "accepted" {
                        let textMessage = TextMessage(serverMessage: message)
                        textMessages.append(textMessage)
                    }
                }
                else {
                    print("Invalid message sender: \(message.fromId!)")
                }
            }
            if !textMessages.isEmpty {
                self.acknowledgeMessages(textMessages)
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

        let contact = contactManager.getContactById(textMessage.contactId)!
        let request = SendMessageRequest(message: textMessage.encodeForServer(publicId: contact.publicId))
        let enclaveTask = EnclaveTask<SendMessageResponse>({ (response: SendMessageResponse) -> Void in
            textMessage.timestamp = Int64(response.timestamp!)
            textMessage.acknowledged = true
            self.messageDatabase.update(textMessage)
            DispatchQueue.main.async {
                AudioServicesPlaySystemSound(MessageManager.sendSoundId)
            }
        })
        enclaveTask.errorTitle = "Message Error"
        enclaveTask.sendRequest(request)
        return messageId

    }

    func updateMessage(_ message: Message) {

        messageDatabase.update(message)

    }

}
