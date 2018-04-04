//
//  ConversationTextHandler.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChattoAdditions

class ConversationTextHandler: BaseMessageInteractionHandlerProtocol {

    typealias ViewModelT = ConversationTextViewModel
    
    private let messageHandler: ConversationMessageHandler

    init (messageHandler: ConversationMessageHandler) {
        self.messageHandler = messageHandler
    }

    func userDidTapOnFailIcon(viewModel: ConversationTextViewModel, failIconView: UIView) {
        
    }
    
    func userDidTapOnAvatar(viewModel: ConversationTextViewModel) {
        
    }
    
    func userDidTapOnBubble(viewModel: ConversationTextViewModel) {
        
    }
    
    func userDidBeginLongPressOnBubble(viewModel: ConversationTextViewModel) {
        
    }
    
    func userDidEndLongPressOnBubble(viewModel: ConversationTextViewModel) {
        
    }
    
    func userDidSelectMessage(viewModel: ConversationTextViewModel) {
        
    }
    
    func userDidDeselectMessage(viewModel: ConversationTextViewModel) {
        
    }
    
}
