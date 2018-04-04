//
//  ConversationSelectorProtocol.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation
import ChattoAdditions

public protocol ConversationSelectorDelegate: class {
    func messagesSelector(_ conversationSelector: ConversationSelectorProtocol,
                          didSelectMessage: MessageModelProtocol)
    func messagesSelector(_ conversationSelector: ConversationSelectorProtocol,
                          didDeselectMessage: MessageModelProtocol)
}

public protocol ConversationSelectorProtocol: class {
    weak var delegate: ConversationSelectorDelegate? { get set }
    var isActive: Bool { get set }
    func canSelectMessage(_ message: MessageModelProtocol) -> Bool
    func isMessageSelected(_ message: MessageModelProtocol) -> Bool
    func selectMessage(_ message: MessageModelProtocol)
    func deselectMessage(_ message: MessageModelProtocol)
    func selectedMessages() -> [MessageModelProtocol]
}
