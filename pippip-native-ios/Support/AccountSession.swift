//
//  AccountSession.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/12/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import UserNotifications

class AccountSession: NSObject, UNUserNotificationCenterDelegate {

    @objc var deviceToken: Data?
    var sessionActive = false
    var suspended = false
    var contactManager = ContactManager()
    var messageManager = MessageManager()
    var suspendTime: Date?

    override init() {
        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(newSession(_:)),
                                               name: Notifications.NewSession, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionEnded(_:)),
                                               name: Notifications.SessionEnded, object: nil)

    }

    func doUpdates() {

        messageManager.getNewMessages()
        contactManager.getPendingRequests()
        contactManager.getRequestStatus(retry: false, publicId: nil)
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }

    }

    @objc func resume() {
        
        if suspended {
            suspended = false
            let resumeTime = Date()
            let suspendedTime = resumeTime.timeIntervalSince(suspendTime!)
            let info = ["suspendedTime": suspendedTime]
            NotificationCenter.default.post(name: Notifications.AppResumed, object: nil, userInfo: info)
            DispatchQueue.main.async {
                if UIApplication.shared.applicationIconBadgeNumber > 0 {
                    self.doUpdates()
                }
            }
        }

    }

    @objc func suspend() {
        
        suspended = true
        suspendTime = Date()
        NotificationCenter.default.post(name: Notifications.AppSuspended, object: nil)

    }

    @objc func newSession(_ notification: Notification) {
        sessionActive = true
    }

    @objc func sessionEnded(_ notification: Notification) {

        sessionActive = false
        contactManager.clearContacts()
        ConversationCache.clearCache()

    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        if sessionActive && !suspended {
            doUpdates()
        }
        completionHandler(.badge)

    }

}
