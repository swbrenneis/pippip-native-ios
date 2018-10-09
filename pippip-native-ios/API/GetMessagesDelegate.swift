//
//  GetMessagesObserver.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class GetMessagesDelegate: EnclaveDelegate<GetMessagesRequest, GetMessagesResponse> {

    var contactManager = ContactManager.instance
    var messageManager = MessageManager()

    override init(request: GetMessagesRequest) {
        super.init(request: request)

        requestComplete = self.getComplete
        requestError = self.getError
        responseError = self.getError

    }

    func getComplete(response: GetMessagesResponse) {

        if response.messages!.count == 0 {
            AsyncNotifier.notify(name: Notifications.GetMessagesComplete, object: nil)
        }
        print("\(response.messages!.count) new messages returned")
        var textMessages = [TextMessage]()
        for message in response.messages! {
            if let contact = contactManager.getContact(publicId: message.fromId!) {
                if contact.status == "accepted" {
                    let textMessage = TextMessage(serverMessage: message)
                    textMessages.append(textMessage)
                    contact.timestamp = textMessage.timestamp / 1000
                    try! contactManager.updateContact(contact)
                }
            }
            else {
                print("Invalid message sender: \(message.fromId!)")
            }
        }
        if !textMessages.isEmpty {
            messageManager.addTextMessages(textMessages)
            messageManager.acknowledgeMessages(textMessages)
        }

    }

    func getError(_ reason: String) {
        NotificationCenter.default.post(name: Notifications.GetMessagesComplete, object: nil)
        print("Get messages error: \(reason)")
    }

}
