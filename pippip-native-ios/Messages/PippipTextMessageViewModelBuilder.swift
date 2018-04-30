//
//  PippipTextMessageViewModelBuilder.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Chatto
import ChattoAdditions

class PippipTextMessageViewModelBuilder: ViewModelBuilderProtocol {

    let messageViewModelBuilder = MessageViewModelDefaultBuilder()

    func createViewModel(_ model: PippipTextMessageModel) -> PippipTextMessageViewModel {
        return PippipTextMessageViewModel(textMessage: model.textMessage)
    }

    func canCreateViewModel(fromModel model: Any) -> Bool {
        return model is PippipTextMessageModel
    }

}
