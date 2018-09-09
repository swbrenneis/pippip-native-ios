//
//  PippipCellStyle.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 9/6/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions

class PippipTextCellStyle: TextMessageCollectionViewCellDefaultStyle {
    
    override func textFont(viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIFont {

        if let textViewModel = viewModel as? TextMessageViewModel<PippipTextMessageModel> {
            let message = textViewModel.textMessage.message
            if message.cleartext == nil {
                return UIFont.italicSystemFont(ofSize: 17.0)
            }
        }
        return super.textFont(viewModel: viewModel, isSelected: isSelected)
        
    }
    
}
