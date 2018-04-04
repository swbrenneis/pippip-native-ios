//
//  TextDataSource.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import Chatto

class TextDataSource: ChatDataSourceProtocol {

    var hasMoreNext = false
    var hasMorePrevious = false
    var chatItems: [ChatItemProtocol]
    
    var delegate: ChatDataSourceDelegateProtocol?
    var scrollingScource : ScrollingDataSource<TextMessage>

    init() {
        chatItems = [ChatItemProtocol]()
    }

    func addTextMessage(_ text: String) {
        // TODO
    }

    func loadNext() {
        // TODO
    }
    
    func loadPrevious() {
        // TODO
    }
    
    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion: (Bool) -> Void) {
        // TODO
    }
    

}
