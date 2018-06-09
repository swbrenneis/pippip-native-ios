//
//  MessageManager.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/5/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

@objc class MessageManager: NSObject {

    static var initialized = false

    var messageDatabase = MessagesDatabase()
    var contactManager = ContactManager()
    var config = Configurator()
    var alertPresenter = AlertPresenter()

    func acknowledgeMessages(_ textMessages: [TextMessage]) {

        var triplets = [Triplet]()
        for textMessage in textMessages {
            if (textMessage.contactId != NSNotFound) {
                let contact = contactManager.getContact(contactId: textMessage.contactId)!
                let triplet = Triplet(publicId: contact.publicId, sequence: Int(textMessage.sequence),
                                      timestamp: Int(textMessage.timestamp))
                triplets.append(triplet)
            }
            else {
                print("Contact for ID \(textMessage.contactId) not found")
            }
        }

        let request = AcknowledgeMessagesRequest(messages: triplets)
        let delegate = AcknowledgeMessagesDelegate(request: request, textMessages: textMessages)
        let messageTask = EnclaveTask<AcknowledgeMessagesRequest, AcknowledgeMessagesResponse>(delegate: delegate)
        messageTask.errorTitle = "Message Error"
        messageTask.sendRequest(request)

    }

    /*
     * Adds incoming messages to the database and to their conversations
     */
    func addTextMessages(_ textMessages: [TextMessage]) {

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
        let delegate = GetMessagesDelegate(request: request)
        let messageTask = EnclaveTask<GetMessagesRequest, GetMessagesResponse>(delegate: delegate)
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
    func sendMessage(_ textMessage: TextMessage, retry: Bool) -> Int64 {

        if (!retry) {
            messageDatabase.add(textMessage)
        }
        let messageId = textMessage.messageId

        let contact = contactManager.getContact(contactId: textMessage.contactId)!
        let request = SendMessageRequest(message: textMessage.encodeForServer(publicId: contact.publicId))
        let delegate = SendMessageDelegate(request: request, textMessage: textMessage)
        let enclaveTask = EnclaveTask<SendMessageRequest ,SendMessageResponse>(delegate: delegate)
        enclaveTask.errorTitle = "Message Error"
        enclaveTask.sendRequest(request)
        return messageId

    }

    func updateMessage(_ message: Message) {

        messageDatabase.update(message)

    }

}
