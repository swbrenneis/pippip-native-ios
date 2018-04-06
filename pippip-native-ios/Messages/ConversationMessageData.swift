//
//  ConversationMessageData.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/5/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ConversationMessageData: MessageData {

    var message: TextMessage
    
    init(_ message: TextMessage) {
        self.message = message
    }

    func contentType() -> MessageDataContentType {
        return kAMMessageDataContentTypeText
    }
    
    func content() -> String {

        if let cleartext = message.cleartext {
            return cleartext
        }
        else {
            return ""
        }

    }
    
    func date() -> Date {

        let tsDouble = Double(message.timestamp)
        return Date(timeIntervalSince1970: tsDouble / 1000)

    }
    
    func senderID() -> String {
        return message.publicId
    }
    
    func senderDisplayName() -> String {

        if let nickname = message.nickname {
            return nickname
        }
        else {
            return message.publicId
        }

    }
    
    func senderAvatarURL() -> URL {

        let path = Bundle.main.path(forResource: "user", ofType: "png")
        return URL(fileURLWithPath: path!)

    }
    
}
