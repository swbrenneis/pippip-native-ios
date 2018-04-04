//
//  ConversationMessagesSelector.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation
import ChattoAdditions

class ConversationMessagesSelector: ConversationSelectorProtocol {

    public weak var delegate: ConversationSelectorDelegate?
    
    var isActive = false {
        didSet {
            guard oldValue != self.isActive else { return }
            if self.isActive {
                self.selectedMessagesDictionary.removeAll()
            }
        }
    }

    private var selectedMessagesDictionary = [String: MessageModelProtocol]()

    func canSelectMessage(_ message: MessageModelProtocol) -> Bool {
        return true
    }
    
    func isMessageSelected(_ message: MessageModelProtocol) -> Bool {
        return self.selectedMessagesDictionary[message.uid] != nil
    }
    
    func selectMessage(_ message: MessageModelProtocol) {
        self.selectedMessagesDictionary[message.uid] = message
        self.delegate?.messagesSelector(self, didSelectMessage: message)
    }
    
    func deselectMessage(_ message: MessageModelProtocol) {
        self.selectedMessagesDictionary[message.uid] = nil
        self.delegate?.messagesSelector(self, didDeselectMessage: message)
    }
    
    func selectedMessages() -> [MessageModelProtocol] {
        return Array(self.selectedMessagesDictionary.values)
    }

}
