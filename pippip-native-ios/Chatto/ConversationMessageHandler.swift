//
//  ConversationMessageHandler.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions

class ConversationMessageHandler {

    private let messageSender: ConversationMessageSender
    private let messagesSelector: ConversationSelectorProtocol

    init(messageSender: ConversationMessageSender, messagesSelector: ConversationSelectorProtocol) {
        self.messageSender = messageSender
        self.messagesSelector = messagesSelector
    }

}
