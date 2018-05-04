//
//  PippipMessageModel.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Chatto
import ChattoAdditions

class PippipMessageModel: MessageModelProtocol {

    var senderId: String
    var isIncoming: Bool
    var date: Date
    var status: MessageStatus
    var type: ChatItemType
    var uid: String

    init(_ message: Message) {

        let contactManager = ContactManager()
        let contact = contactManager.getContactById(message.contactId)!

        senderId = contact.displayName
        isIncoming = !message.originating
        date = Date(timeIntervalSince1970: Double(message.timestamp) / 1000)
        status = .success
        type = "text-message-type"
        uid = "\(message.messageId)"

    }

}
