//
//  ConversationTextModel.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions

class ConversationTextModel: TextMessageModel<MessageModel>, ConversationModelProtocol {

    var status: MessageStatus = .success
    let chatItemType: ChatItemType = "text"

    public override init(messageModel: MessageModel, text: String) {
        super.init(messageModel: messageModel, text: text)
    }

}
