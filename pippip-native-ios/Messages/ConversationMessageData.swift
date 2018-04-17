//
//  ConversationMessageData.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/5/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ConversationMessageData: MessageData {

    var message: TextMessage?
    var publicId: String
    var displayName: String

    init() {

        publicId = ""
        displayName = ""

    }

    init(_ message: TextMessage, contact: Contact) {

        self.message = message
        publicId = contact.publicId
        displayName = contact.displayName

    }

    func contentType() -> MessageDataContentType {
        return kAMMessageDataContentTypeText
    }
    
    func content() -> String {

        if let cleartext = message?.cleartext {
            return cleartext
        }
        else {
            return ""
        }

    }
    
    func date() -> Date {

        if let timestamp = message?.timestamp {
            return Date(timeIntervalSince1970: Double(timestamp) / 1000.0)
        }
        else {
            return Date()
        }

    }
    
    func senderID() -> String {
        return publicId
    }
    
    func senderDisplayName() -> String {

        return displayName

    }
    
    func senderAvatarURL() -> URL {
        // This doesn't work
        let path = Bundle.main.path(forResource: "user", ofType: "png")
        return URL(fileURLWithPath: path!)

    }
    
}
