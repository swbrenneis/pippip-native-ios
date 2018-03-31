//
//  ConversationTextViewModel.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions

class ConversationTextViewModel: TextMessageViewModel<ConversationTextModel> {
    
    public override init(textMessage: ConversationTextModel, messageViewModel: MessageViewModelProtocol) {
        super.init(textMessage: textMessage, messageViewModel: messageViewModel)
    }

}
