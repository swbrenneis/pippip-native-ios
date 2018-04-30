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

    var textMessage: TextMessage
    
    init(textMessage: TextMessage) {

        self.textMessage = textMessage
        var messageText: String!
        if textMessage.cleartext != nil {
            messageText = textMessage.cleartext!
        }
        else if textMessage.ciphertext!.count < 100 {
            textMessage.decrypt(true)   // No notification
            messageText = textMessage.cleartext!
        }
        else {
            textMessage.decrypt()
            messageText = "Processing..."
        }
        super.init(messageModel: PippipMessageModel(textMessage), text: messageText)

    }
    
}

