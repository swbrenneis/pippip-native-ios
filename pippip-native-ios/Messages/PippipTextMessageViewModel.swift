//
//  ChattoTextMessageViewModel.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Chatto
import ChattoAdditions

// This class is currently unused.
class PippipTextMessageViewModel: TextMessageViewModel<PippipTextMessageModel> {

    init(textMessageModel: PippipTextMessageModel, messageModel: PippipMessageModel) {

        super.init(textMessage: textMessageModel,
                   messageViewModel: PippipMessageViewModel(model: messageModel))

    }

}
