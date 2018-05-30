//
//  Notifications.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/24/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

struct Notifications {

    static let AccountDeleted = NSNotification.Name("AccountDeleted")
    static let AppResumed = NSNotification.Name("AppResumed")
    static let AppSuspended = NSNotification.Name("AppSuspended")
    static let Authenticated = NSNotification.Name("Authenticated")
    static let CleartextAvailable = NSNotification.Name("CleartextAvailable")
    static let ContactDeleted = NSNotification.Name("ContactDeleted")
    static let ContactRequested = NSNotification.Name("ContactRequested")
    static let ContactSelected = NSNotification.Name("ContactSelected")
    static let EnclaveRequestComplete = NSNotification.Name("EnclaveRequestComplete")
    static let FriendAdded = NSNotification.Name("FriendAdded")
    static let FriendDeleted = NSNotification.Name("FriendDeleted")
    static let NewMessages = NSNotification.Name("NewMessages")
    static let NicknameMatched = NSNotification.Name("NicknameMatched")
    static let PolicyChanged = NSNotification.Name("PolicyChanged")
    static let PolicyUpdated = NSNotification.Name("PolicyUpdated")
    static let PostComplete = NSNotification.Name("PostComplete")
    static let PresentAlert = NSNotification.Name("PresentAlert")
    static let MessagesUpdated = NSNotification.Name("MessagesUpdated")
    static let NewSession = NSNotification.Name("NewSession")
    static let NicknameUpdated = NSNotification.Name("NicknameUpdated")
    static let RequestAcknowledged = NSNotification.Name("RequestsAcknowledged")
    static let RequestStatusUpdated = NSNotification.Name("RequestStatusUpdated")
    static let RequestsUpdated = NSNotification.Name("RequestsUpdated")
    static let SessionEnded = NSNotification.Name("SessionEnded")
    static let SessionStarted = NSNotification.Name("SessionStarted")
    static let ThumbprintComplete = NSNotification.Name("ThumbprintComplete")
    static let UpdateProgress = NSNotification.Name("UpdateProgress")

}
