//
//  Notifications.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/24/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

struct Notifications {

    static let AppWillResume = NSNotification.Name("AppWillResume")
    static let AppResumed = NSNotification.Name("AppResumed")
    static let AppWillSuspend = NSNotification.Name("AppWillSuspend")
    static let AppSuspended = NSNotification.Name("AppSuspended")
    static let AppWillTerminate = NSNotification.Name("AppWillTerminate")
    static let AuthComplete = NSNotification.Name("AuthComplete")
    static let CleartextAvailable = NSNotification.Name("CleartextAvailable")
    static let ContactDeleted = NSNotification.Name("ContactDeleted")
    static let ContactRequested = NSNotification.Name("ContactRequested")
    static let ContactSelected = NSNotification.Name("ContactSelected")
    static let ConversationDeleted = NSNotification.Name("ConversationDeleted")
    static let DirectoryIdMatched = NSNotification.Name("DirectoryIdMatched")
    static let DirectoryIdSet = NSNotification.Name("DirectoryIdSet")       // Posted when contact directory ID set
    static let DirectoryIdUpdated = NSNotification.Name("DirectoryIdUpdated")
    static let EnclaveRequestComplete = NSNotification.Name("EnclaveRequestComplete")
    static let GetMessagesComplete = NSNotification.Name("GetMessagesComplete")
    static let GetRequestsComplete = NSNotification.Name("GetRequestsComplete")
    static let GetStatusComplete = NSNotification.Name("GetStatusComplete")
    static let MessageBubbleTapped = NSNotification.Name("MessageBubbleTapped")
    static let MessageDeleted = NSNotification.Name("MessageDeleted")
    static let MessageFailed = NSNotification.Name("MessageFailed")
    static let MessageSent = NSNotification.Name("MessageSent")
    static let NewMessages = NSNotification.Name("NewMessages")
    static let NewMessagesAdded = NSNotification.Name("NewMessagesAdded")
    static let ParametersGenerated = NSNotification.Name("ParametersGenerated")
    static let PassphraseReady = NSNotification.Name("PassphraseReady")
    static let PolicyChanged = NSNotification.Name("PolicyChanged")
    static let PolicyUpdated = NSNotification.Name("PolicyUpdated")
    static let PostComplete = NSNotification.Name("PostComplete")
    static let PresentAlert = NSNotification.Name("PresentAlert")
    static let RequestAcknowledged = NSNotification.Name("RequestsAcknowledged")
    static let RequestStatusUpdated = NSNotification.Name("RequestStatusUpdated")
    static let RequestsUpdated = NSNotification.Name("RequestsUpdated")
    static let ResetControllers = NSNotification.Name("ResetControllers")
    static let RetryMessage = NSNotification.Name("RetryMessage")
    static let SessionEnded = NSNotification.Name("SessionEnded")
    static let SessionStarted = NSNotification.Name("SessionStarted")
    static let SetContactBadge = NSNotification.Name("SetContactBadge")
    static let WhitelistEntryAdded = NSNotification.Name("WhitelistEntryAdded")
    static let WhitelistEntryDeleted = NSNotification.Name("WhitelistEntryDeleted")

}
