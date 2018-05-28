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

    init(model: PippipMessageModel) {

        decorationAttributes = BaseMessageDecorationAttributes()
        isIncoming = model.isIncoming
        isUserInteractionEnabled = false
        isShowingFailedIcon = model.status == .failed
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter .dateStyle = .medium
        date = formatter.string(from: model.date)
        avatarImage = Observable(UIImage(named: "avatar-user-small"))
        switch model.status {
        case .sending:
            status = .sending
            break
        case .success:
            status = .success
            break
        case .failed:
            status = .failed
            break
        }

    }

}
