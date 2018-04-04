//
//  TextMessageModel.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChattoAdditions

class TextMessageModel: TextMessageModelProtocol {

    static let chatItemType = "text"
    
    var text: String
    var messageModel: MessageModelProtocol

    init() {
        text = "Some text"
        messageModel = MessageModel(uid: "", senderId: "", type: "", isIncoming: false, date: Date(), status: .success)
    }

}
