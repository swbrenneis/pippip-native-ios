//
//  PippipTextMessageInteractionHandler.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Chatto
import ChattoAdditions

class PippipTextMessageInteractionHandler: BaseMessageInteractionHandlerProtocol {

    init() {
        
    }

    func userDidTapOnFailIcon(viewModel: TextMessageViewModel<PippipTextMessageModel>, failIconView: UIView) {

        let message = viewModel.textMessage.message
        NotificationCenter.default.post(name: Notifications.RetryMessage, object: message)

    }

    func userDidTapOnAvatar(viewModel: TextMessageViewModel<PippipTextMessageModel>) {
        
    }

    func userDidTapOnBubble(viewModel: TextMessageViewModel<PippipTextMessageModel>) {

        let message = viewModel.textMessage.message
        NotificationCenter.default.post(name: Notifications.MessageBubbleTapped, object: message)
        
    }

    func userDidBeginLongPressOnBubble(viewModel: TextMessageViewModel<PippipTextMessageModel>) {
        
    }

    func userDidEndLongPressOnBubble(viewModel: TextMessageViewModel<PippipTextMessageModel>) {
        
    }

    func userDidSelectMessage(viewModel: TextMessageViewModel<PippipTextMessageModel>) {
        
    }

    func userDidDeselectMessage(viewModel: TextMessageViewModel<PippipTextMessageModel>) {
        
    }

}
