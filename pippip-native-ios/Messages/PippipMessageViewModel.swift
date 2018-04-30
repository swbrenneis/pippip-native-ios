//
//  PippipMessageViewModel.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Chatto
import ChattoAdditions

class PippipMessageViewModel: MessageViewModelProtocol {
    
    var decorationAttributes: BaseMessageDecorationAttributes
    var isIncoming: Bool
    var isUserInteractionEnabled: Bool
    var isShowingFailedIcon: Bool
    var date: String
    var status: MessageViewModelStatus
    var avatarImage: Observable<UIImage?>

    init(message: Message) {

        decorationAttributes = BaseMessageDecorationAttributes()
        isIncoming = !message.originating
        isUserInteractionEnabled = false
        isShowingFailedIcon = false
        let dateTime = Date(timeIntervalSince1970: Double(message.timestamp) / 1000)
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter .dateStyle = .medium
        date = formatter.string(from: dateTime)
        status = .success
        avatarImage = Observable(UIImage(named: "avatar-user-small"))

    }

}
