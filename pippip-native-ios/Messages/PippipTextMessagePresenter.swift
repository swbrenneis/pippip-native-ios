//
//  PippipTextMessagePresenter.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 9/5/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChattoAdditions
import Chatto

class PippipTextMessagePresenter: TextMessagePresenter<PippipTextMessageViewModelBuilder, PippipTextMessageInteractionHandler> {

    var messageManager = MessageManager()
    
    open override func canPerformMenuControllerAction(_ action: Selector) -> Bool {
        let copySelector = #selector(UIResponderStandardEditActions.copy(_:))
        let cutSelector = #selector(UIResponderStandardEditActions.cut(_:))
        let canDo = action == copySelector || action == cutSelector
        return canDo
    }

    open override func performMenuControllerAction(_ action: Selector) {
        let copySelector = #selector(UIResponderStandardEditActions.copy(_:))
        let cutSelector = #selector(UIResponderStandardEditActions.cut(_:))
        if action == copySelector {
            UIPasteboard.general.string = self.messageViewModel.text
        }
        else if action == cutSelector {
            let message = self.messageViewModel.textMessage.message
            MessagesModel.instance.deleteMessage(messageId: message.messageId)
            NotificationCenter.default.post(name: Notifications.MessageDeleted, object: message)
        }
        else {
            assert(false, "Unexpected action")
        }
    }

}
