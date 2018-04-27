//
//  MutableTextBubbleNode.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/26/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework
import AsyncDisplayKit

class MutableTextBubbleNodeFactory: MessageBubbleNodeFactory {

    func build(message: MessageData, isOutgoing: Bool, bubbleImage: UIImage) -> ASDisplayNode {
        let bubbleNode =  MutableTextBubbleNode(placeholder: "Processing...", messageData: message,
                                                isOutgoing: isOutgoing, bubbleImage: bubbleImage)
        DispatchQueue.global(qos: .background).async {
            bubbleNode.messageData.message!.decrypt()
        }
        return bubbleNode

    }

}

class MutableTextBubbleNode: MessageTextBubbleNode {

    let outgoingMessageAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(UIColor.flatWhiteDark,
                                                                                            returnFlat: true),
                                     NSAttributedStringKey.font: UIFont.italicSystemFont(ofSize: 14)
    ]
    let incomingMessageAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(UIColor.flatPowderBlueDark,
                                                                                            returnFlat: true),
                                     NSAttributedStringKey.font: UIFont.italicSystemFont(ofSize: 14)
    ]
    
    var messageData: ConversationMessageData
    var attributes: [NSAttributedStringKey: Any]

    init(placeholder: String, messageData: MessageData, isOutgoing: Bool, bubbleImage: UIImage) {

        assert(messageData.self is ConversationMessageData)
        self.messageData = messageData as! ConversationMessageData
        attributes = isOutgoing ? outgoingMessageAttributes : incomingMessageAttributes
        let text = NSAttributedString(string: placeholder, attributes: attributes)
        
        super.init(text: text, isOutgoing: isOutgoing, bubbleImage: bubbleImage)

        NotificationCenter.default.addObserver(self, selector: #selector(cleartextAvailable(_:)),
                                               name: Notifications.CleartextAvailable, object: nil)

    }

    @objc func cleartextAvailable(_ notification: Notification) {

        guard let message = notification.object as? TextMessage else { return }
        if message.messageId == messageData.messageId() {
            NotificationCenter.default.removeObserver(self, name: Notifications.CleartextAvailable, object: nil)
            messageData.message = message
            DispatchQueue.main.async {
                var node: ASDisplayNode? = self
                repeat {
                    node?.invalidateCalculatedLayout()
                    node?.setNeedsLayout()
                    node = node?.supernode
                } while node != nil
            }
        }

    }

}
