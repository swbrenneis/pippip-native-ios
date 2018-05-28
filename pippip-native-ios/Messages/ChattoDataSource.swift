//
//  ChattoDataSource.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Chatto
import ChattoAdditions
import AudioToolbox

class ChattoDataSource: ChatDataSourceProtocol {

    var hasMoreNext: Bool {
        get {
            return slidingWindow.canSlideDown()
        }
    }
    var hasMorePrevious: Bool {
        get {
            return slidingWindow.canSlideUp()
        }
    }
    var chatItems: [ChatItemProtocol] {
        return slidingWindow.items
    }
    var visible = false
    var delegate: ChatDataSourceDelegateProtocol?
    var slidingWindow: SlidingMessageWindow

    init(conversation: Conversation) {

        slidingWindow = SlidingMessageWindow(conversation: conversation, windowSize: 15)

        NotificationCenter.default.addObserver(self, selector: #selector(newMessages(_:)),
                                               name: Notifications.NewMessages, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cleartextAvailable(_:)),
                                               name: Notifications.CleartextAvailable, object: nil)
/*        NotificationCenter.default.addObserver(self, selector: #selector(appResumed(_:)),
                                               name: Notifications.AppResumed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appSuspended(_:)),
                                               name: Notifications.AppSuspended, object: nil) */

    }

    func loadNext() {
        slidingWindow.slideDown()
        delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
    }
    
    func loadPrevious() {
        slidingWindow.slideUp()
        delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
    }
    
    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion: (Bool) -> Void) {

        completion(false)

    }
    
    func addTextMessage(_ textMessage: TextMessage) {

        slidingWindow.insertMessage(textMessage)
        delegate?.chatDataSourceDidUpdate(self, updateType: .normal)

    }

    func clearMessages() {

        assert(Thread.isMainThread, "clearMessages not called from main thread")
        slidingWindow.clearMessages()
        delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)

    }

    @objc func newMessages(_ notification: Notification) {

        DispatchQueue.main.async {
            if self.slidingWindow.newMessages() {
                self.delegate?.chatDataSourceDidUpdate(self, updateType: .normal)
                if self.visible {
                    DispatchQueue.main.async {
                        AudioServicesPlaySystemSound(MessageManager.receiveSoundId)
                    }
                }
            }
        }
        
    }

    @objc func cleartextAvailable(_ notification: Notification) {

        if let textMessage = notification.object as? TextMessage {
            DispatchQueue.main.async {
                self.slidingWindow.updateChatItem(textMessage)
                self.delegate?.chatDataSourceDidUpdate(self, updateType: .reload)
            }
        }

    }
/*
    @objc func appResumed(_ notification: Notification) {

        DispatchQueue.main.async {
            self.slidingWindow.resume()
            self.delegate?.chatDataSourceDidUpdate(self, updateType: .normal)
        }

    }

    @objc func appSuspended(_ notification: Notification) {

        DispatchQueue.main.async {
            self.slidingWindow.suspend()
            self.delegate?.chatDataSourceDidUpdate(self, updateType: .normal)
        }

    }
*/
}
