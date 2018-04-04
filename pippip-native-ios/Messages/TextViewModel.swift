//
//  TextViewModel.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChattoAdditions

class TextViewModel: TextMessageViewModelProtocol {

    var text: String {
        return textMessage.text
    }
    var textMessage: TextMessageModelProtocol
    var messageViewModel: MessageViewModelProtocol
    
    public init(textMessage: TextMessageModelProtocol, messageViewModel: MessageViewModelProtocol) {
        self.textMessage = textMessage
        self.messageViewModel = messageViewModel
    }
    
//    class TextViewModel: TextMessageViewModel<TextMessageModel> {

}
