//
//  SlidingMessageWindow.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import Chatto

class SlidingMessageWindow: NSObject {

    var conversation: Conversation
    var windowSize: Int
    var windowPos: Int
    var window: [TextMessage]
    var items: [PippipTextMessageModel]
    var visible: Bool = false {
        didSet {
            if visible {
                conversation.markMessagesRead(window)
            }
        }
    }

    init(conversation: Conversation, windowSize: Int) {

        self.conversation = conversation
        self.windowSize = windowSize

        windowPos = max(0, conversation.messageCount - windowSize)
        window = conversation.getMessages(pos: windowPos, count: windowSize)
        items = [PippipTextMessageModel]()
        for textMessage in window {
            items.append(PippipTextMessageModel(textMessage: textMessage))
        }
        conversation.markMessagesRead(window)

    }

    func canSlideDown() -> Bool {

        return windowPos + window.count < conversation.messageCount

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
        window.append(textMessage)
        items.append(PippipTextMessageModel(textMessage: textMessage))

    }

    func newMessages() -> Bool {

        let newMessages = conversation.newMessages
        if newMessages.count > 0 {
            for message in newMessages {
                items.append(PippipTextMessageModel(textMessage: message))
            }
            window.append(contentsOf: newMessages)
            if visible {
                conversation.markMessagesRead(newMessages)
            }
            return true
        }
        else {
            return false
        }

    }

    func slideDown() {

        if canSlideDown() {
            windowPos = min(windowPos + windowSize, windowPos + (conversation.messageCount - windowSize))
            conversation.markMessagesRead(window)
        }

    }

    func slideUp() {

        if canSlideUp() {
            windowPos = max(0, windowPos - windowSize)
            let newSize = min(windowSize, conversation.messageCount - window.count)
            var newWindow = conversation.getMessages(pos: windowPos, count: newSize)
            var newItems = [PippipTextMessageModel]()
            for message in newWindow {
                newItems.append(PippipTextMessageModel(textMessage: message))
            }
            newWindow.append(contentsOf: window)
            window = newWindow
            newItems.append(contentsOf: items)
            items = newItems
        }

    }
/*
    func suspend() {

        suspendedItems = items
        items.removeAll()
    
    }
*/
    func updateChatItem(_ textMessage: TextMessage) {

        for index in 0..<window.count {
            if window[index].messageId == textMessage.messageId {
                items[index] = PippipTextMessageModel(textMessage: textMessage)
            }
        }

    }

}
