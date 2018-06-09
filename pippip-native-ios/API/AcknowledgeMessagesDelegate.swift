//
//  AcknowledgeMessagesObserver.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class AcknowledgeMessagesDelegate: EnclaveDelegate<AcknowledgeMessagesRequest, AcknowledgeMessagesResponse> {

    var textMessages: [TextMessage]
    var messageManager = MessageManager()

    init(request: AcknowledgeMessagesRequest, textMessages: [TextMessage]) {

        self.textMessages = textMessages

        super.init(request: request)

        requestComplete = self.ackComplete
        requestError = self.ackError
        
    }

    func ackComplete(response: AcknowledgeMessagesResponse) {

        print("Messages acknowledged, \(response.exceptions!.count) exceptions")
        for textMessage in textMessages {
            textMessage.acknowledged = true
        }
        messageManager.addTextMessages(textMessages)
        NotificationCenter.default.post(name: Notifications.NewMessages, object: textMessages)

    }

    func ackError(error: EnclaveResponseError) {
        print("Acknowledge messages error: \(error.errorString!)")
    }

}
