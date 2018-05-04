//
//  TextMessageDecorator.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Chatto
import ChattoAdditions

class TextMessageDecorator: ChatItemsDecoratorProtocol {

    init() {
    }

    func decorateItems(_ chatItems: [ChatItemProtocol]) -> [DecoratedChatItem] {

        var decoratedItems = [DecoratedChatItem]()
        for index in 0..<chatItems.count {
            let chatItem = chatItems[index] as! PippipTextMessageModel
            var showingTail = true
            var bottomMargin: CGFloat = 15.0
            if index < chatItems.count - 1 {
                let nextItem = chatItems[index + 1] as! PippipTextMessageModel
                if chatItem.message.originating == nextItem.message.originating {
                    showingTail = false
                    bottomMargin = 1.0
                }
            }
            let messageDecorationAttributes = BaseMessageDecorationAttributes(canShowFailedIcon: true,
                                                                              isShowingTail: showingTail,
                                                                              isShowingAvatar: false,
                                                                              isShowingSelectionIndicator: false,
                                                                              isSelected: false)
            let decorationAttributes =
                ChatItemDecorationAttributes(bottomMargin: bottomMargin,
                                             messageDecorationAttributes: messageDecorationAttributes)
            let decoratedItem = DecoratedChatItem(uid: chatItem.uid, chatItem: chatItem,
                                                  decorationAttributes: decorationAttributes)

            decoratedItems.append(decoratedItem)
        }
        return decoratedItems

    }

}

