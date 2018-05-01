//
//  TextChatItemFactory.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Chatto
import ChattoAdditions

class TextChatItemFactory {

    // Return a single chat item. Used for sent messages
    func makeChatItem(_ textMessage: TextMessage) -> ChatItemProtocol {
        return PippipTextMessageModel(textMessage: textMessage)
    }

    // Returns a sorted array of chat items
    func makeChatItems(_ textMessages: [TextMessage]) -> [ChatItemProtocol] {

        var chatItems = [ChatItemProtocol]()
        for textMessage in textMessages {
            chatItems.append(PippipTextMessageModel(textMessage: textMessage))
        }
        return chatItems

    }

}
