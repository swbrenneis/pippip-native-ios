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

        window = conversation.getMessages(pos: 0, count: windowSize)
        // Always move the window to the end of the list
        if (window.count < windowSize) {
            windowPos = 0
        }
        else {
            windowPos = conversation.messageCount - windowSize
        }
        conversation.markMessagesRead(window)

    }

    func canSlideDown() -> Bool {

        return windowPos + windowSize < conversation.messageCount

    }

    func canSlideUp() -> Bool {

        return windowPos > 0

    }

    func clearMessages() {

        conversation.clearMessages()
        windowPos = 0
        window.removeAll()

    }

    func insertMessage(_ textMessage: TextMessage) {

        conversation.addTextMessages([textMessage])
        if window.count == windowSize {
            windowPos = min(windowPos + 1, conversation.messageCount - 1)
        }
        window = conversation.getMessages(pos: windowPos, count: windowSize)

    }

    func newMessages() {

        if window.count == windowSize {
            windowPos += conversation.newMessageCount()
        }
        window = conversation.getMessages(pos: windowPos, count: windowSize)
        conversation.markMessagesRead(window)

    }

    func slideDown() {

        if canSlideDown() {
            windowPos = min(conversation.messageCount - 1, windowPos + (windowSize / 2))
            window = conversation.getMessages(pos: windowPos, count: windowSize)
            conversation.markMessagesRead(window)
        }

    }

    func slideUp() {

        if canSlideUp() {
            windowPos -= max(0, windowSize - (windowSize / 2))
            window = conversation.getMessages(pos: windowPos, count: windowSize)
        }

    }

}
