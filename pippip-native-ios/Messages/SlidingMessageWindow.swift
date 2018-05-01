//
//  SlidingMessageWindow.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class SlidingMessageWindow: NSObject {

    var conversation: Conversation
    var windowSize: Int
    var windowPos: Int
    // Sorted, newest last
    var window: [TextMessage]

    init(conversation: Conversation, windowSize: Int) {

        self.conversation = conversation
        self.windowSize = windowSize

        window = conversation.getMessages(pos: 0, count: windowSize).reversed()
        if (window.count < windowSize) {
            windowPos = 0
        }
        else {
            windowPos = conversation.messageCount - windowSize
        }

    }

    func canSlideDown() -> Bool {

        return windowPos < conversation.messageCount

    }

    func canSlideUp() -> Bool {

        return windowPos > 0

    }

    func insertMessage(_ textMessage: TextMessage) {

        conversation.addTextMessages([textMessage])
        windowPos += 1
        window = conversation.getMessages(pos: windowPos, count: windowSize)

    }

    func slideDown() {

        if canSlideDown() {
            windowPos += windowSize / 2
            window = conversation.getMessages(pos: windowPos, count: windowSize)
        }

    }

    func slideUp() {

        if canSlideUp() {
            windowPos -= windowSize / 2
            if windowPos < 0 {
                windowPos = 0
            }
            window = conversation.getMessages(pos: windowPos, count: windowSize)
        }

    }

}
