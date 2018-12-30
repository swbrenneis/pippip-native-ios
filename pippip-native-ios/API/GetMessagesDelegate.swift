//
//  GetMessagesObserver.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import CocoaLumberjack

class GetMessagesDelegate: EnclaveDelegate<GetMessagesRequest, GetMessagesResponse> {

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
        DDLogError("\(response.messages!.count) new messages returned")
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
            let messageManager = MessageManager()
            MessagesModel.instance.addTextMessages(textMessages)
            messageManager.acknowledgeMessages(textMessages)
        }

    }

    func getError(_ reason: String) {
        NotificationCenter.default.post(name: Notifications.GetMessagesComplete, object: nil)
        DDLogError("Get messages error: \(reason)")
    }

}
