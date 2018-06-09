//
//  SendMessageObserver.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import AudioToolbox

class SendMessageDelegate: EnclaveDelegate<SendMessageRequest, SendMessageResponse> {

    static var sendSoundId: SystemSoundID = 0
    var textMessage: TextMessage
    var messageManager = MessageManager()

    init(request: SendMessageRequest, textMessage: TextMessage) {
        
        self.textMessage = textMessage
        
        super.init(request: request)

        requestComplete = self.sendComplete
        requestError = self.sendError

        if SendMessageDelegate.sendSoundId == 0 {
            if let sendUrl = Bundle.main.url(forResource: "iphone_send_sms", withExtension: "mp3") {
                AudioServicesCreateSystemSoundID(sendUrl as CFURL, &SendMessageDelegate.sendSoundId)
            }
        }

    }

    func sendComplete(response: SendMessageResponse) {
        
        textMessage.timestamp = Int64(response.timestamp!)
        textMessage.acknowledged = true
        messageManager.updateMessage(textMessage)
        DispatchQueue.main.async {
            AudioServicesPlaySystemSound(SendMessageDelegate.sendSoundId)
            NotificationCenter.default.post(name: Notifications.MessageSent, object: self.textMessage.messageId)
        }

    }

    func sendError(error: EnclaveResponseError) {
        print("Send message error: \(error.errorString!)")
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notifications.MessageFailed, object: self.textMessage)
        }
    }

}
