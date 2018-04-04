//
//  ConversationViewModelBuilder.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions

class ConversationViewModelBuilder: ViewModelBuilderProtocol {

    typealias ModelT = ConversationTextModel
    typealias ViewModelT = ConversationTextViewModel

    let messageViewModelBuilder = MessageViewModelDefaultBuilder()

    func canCreateViewModel(fromModel model: Any) -> Bool {
        return model is ConversationTextModel
    }
    
    func createViewModel(_ model: ConversationTextModel) -> ConversationTextViewModel {
        let messageViewModel = self.messageViewModelBuilder.createMessageViewModel(model)
        let textViewModel = ConversationTextViewModel(textMessage: model, messageViewModel: messageViewModel)
        return textViewModel
    }
    
}
