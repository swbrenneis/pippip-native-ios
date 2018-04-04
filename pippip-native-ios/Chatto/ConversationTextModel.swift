//
//  ConversationTextModel.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions

public protocol ConversationModelProtocol: MessageModelProtocol {
    // Override for read-write access
    var status: MessageStatus { get set }
}

class ConversationTextModel: TextMessageModel, ConversationModelProtocol {

    var status: MessageStatus = .success

}

