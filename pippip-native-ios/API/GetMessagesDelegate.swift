//
//  GetMessagesObserver.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class GetMessagesDelegate: EnclaveDelegate<GetMessagesRequest, GetMessagesResponse> {

    var contactManager = ContactManager()
    var messageManager = MessageManager()

    override init(request: GetMessagesRequest) {
        super.init(request: request)

        requestComplete = self.getComplete
        requestError = self.getError

    }

    func getComplete(response: GetMessagesResponse) {
        
        print("\(response.messages!.count) new messages returned")
        var textMessages = [TextMessage]()
        for message in response.messages! {
            if let contact = contactManager.getContact(publicId: message.fromId!) {
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
            messageManager.acknowledgeMessages(textMessages)
        }

    }

    func getError(error: EnclaveResponseError) {
        print("Get messages error: \(error.errorString!)")
    }

}