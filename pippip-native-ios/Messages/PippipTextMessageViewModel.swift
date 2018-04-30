//
//  ChattoTextMessageViewModel.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Chatto
import ChattoAdditions

class PippipTextMessageViewModel: TextMessageViewModel<PippipTextMessageModel> {

    init(textMessage: TextMessage) {

        super.init(textMessage: PippipTextMessageModel(textMessage: textMessage),
                   messageViewModel: PippipMessageViewModel(message: textMessage))

    }

}
