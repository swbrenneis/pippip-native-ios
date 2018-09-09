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

    var message: TextMessage
    var messageText: String
    var pippipMessageModel: PippipMessageModel

    init(textMessage: TextMessage) {

        message = textMessage
        pippipMessageModel = PippipMessageModel(message: textMessage)
        messageText = textMessage.cleartext ?? "Text not available"
        super.init(messageModel: pippipMessageModel, text: messageText)

    }

}

