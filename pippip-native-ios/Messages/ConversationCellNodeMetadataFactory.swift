//
//  ConversationCellNodeMetadataFactory.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/6/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ConversationCellNodeMetadataFactory: MessageCellNodeMetadataFactory {

    override func buildMetadatas(for messages: [MessageData], currentUserID: String?) -> [MessageCellNodeMetadata] {

        var metas = [MessageCellNodeMetadata]()

        for messageData in messages {
            if let textData = messageData as? ConversationMessageData {
                let meta = MessageCellNodeMetadata(isOutgoing: textData.message.originating,
                                                   showsSenderName: false,
                                                   showsSenderAvatar: false,
                                                   showsTailForBubbleImage: true,
                                                   showsDate: false)
                metas.append(meta)
            }
        }
        return metas;

    }

}
