//
//  TextPresenterBuilder.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChattoAdditions

class TextPresenterBuilder: TextMessagePresenterBuilder<TextViewModelBuilder,TextInteractionHandler> {

    init() {
        // TODO
        super.init(viewModelBuilder: TextViewModelBuilder())
    }

}
