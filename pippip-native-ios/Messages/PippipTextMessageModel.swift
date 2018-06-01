//
//  PippipTextMessageModelBuilder.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Chatto
import ChattoAdditions

class PippipTextMessageModel: TextMessageModel<PippipMessageModel> {

    var message: Message
    var messageText = "Processing..."
    var pippipMessageModel: PippipMessageModel

    init(textMessage: TextMessage) {

        message = textMessage
        pippipMessageModel = PippipMessageModel(textMessage)
        if textMessage.cleartext != nil {
            messageText = textMessage.cleartext!
        }
        else if textMessage.ciphertext!.count < 50 {
            textMessage.decrypt(noNotify: true)
            messageText = textMessage.cleartext!
        }
        else {
            DispatchQueue.global(qos: .background).async {
                textMessage.decrypt(noNotify: false)
            }
        }
        super.init(messageModel: pippipMessageModel, text: messageText)

    }

}

