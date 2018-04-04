//
//  Notifications.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/24/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

@objc class Notifications: NSObject {

    static let AccountDeleted = NSNotification.Name("AccountDeleted")
    static let Authenticated = NSNotification.Name("Authenticated")
    static let NewSession = NSNotification.Name("NewSession")
    static let AppResumed = NSNotification.Name("AppResumed")
    static let AppSuspended = NSNotification.Name("AppSuspended")
    static let FriendAdded = NSNotification.Name("FriendAdded")
    static let FriendDeleted = NSNotification.Name("FriendDeleted")
    static let NicknameMatched = NSNotification.Name("NicknameMatched")
    static let PresentAlert = NSNotification.Name("PresentAlert")
    static let PolicyUpdated = NSNotification.Name("PolicyUpdated")
    static let ContactDeleted = NSNotification.Name("ContactDeleted")
    static let ContactRequested = NSNotification.Name("ContactRequested")
    static let ContactsSynchronized = NSNotification.Name("ContactsSynchronized")
    static let RequestsUpdated = NSNotification.Name("RequestsUpdated")
    static let RequestAcknowledged = NSNotification.Name("RequestsAcknowledged")
    static let UpdateProgress = NSNotification.Name("UpdateProgress")
    static let ContactsUpdated = NSNotification.Name("ContactsUpdated")

}
