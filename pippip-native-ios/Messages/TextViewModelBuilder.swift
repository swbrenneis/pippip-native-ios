//
//  TextViewModelBuilder.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChattoAdditions

class TextViewModelBuilder: ViewModelBuilderProtocol {
    typealias ModelT = TextMessageModel
    typealias ViewModelT = TextViewModel
    

    let messageViewModelBuilder = MessageViewModelDefaultBuilder()

    func canCreateViewModel(fromModel model: Any) -> Bool {
        return model is TextMessageModel
    }

    func createViewModel(_ model: TextMessageModel) -> ViewModelT {
        let messageViewModel = messageViewModelBuilder.createMessageViewModel(model)
        return TextViewModel(textMessage: model, messageViewModel: messageViewModel)
    }

}
