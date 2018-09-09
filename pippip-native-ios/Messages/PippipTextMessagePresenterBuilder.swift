//
//  PippipTextMessagePresenterBuilder.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 9/5/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions

class PippipTextMessagePresenterBuilder: TextMessagePresenterBuilder<PippipTextMessageViewModelBuilder, PippipTextMessageInteractionHandler> {
    
    override func createPresenter(withChatItem chatItem: ChatItemProtocol,
                                  viewModelBuilder: PippipTextMessageViewModelBuilder,
                                  interactionHandler: PippipTextMessageInteractionHandler?,
                                  sizingCell: TextMessageCollectionViewCell,
                                  baseCellStyle: BaseMessageCollectionViewCellStyleProtocol,
                                  textCellStyle: TextMessageCollectionViewCellStyleProtocol,
                                  layoutCache: NSCache<AnyObject, AnyObject>) -> PippipTextMessagePresenter {
        assert(self.canHandleChatItem(chatItem))
        return PippipTextMessagePresenter(
            messageModel: chatItem as! PippipTextMessageModel,
            viewModelBuilder: viewModelBuilder,
            interactionHandler: interactionHandler,
            sizingCell: sizingCell,
            baseCellStyle: baseCellStyle,
            textCellStyle: textCellStyle,
            layoutCache: layoutCache
        )
    }

}
