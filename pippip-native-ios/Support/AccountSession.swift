//
//  AccountSession.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/12/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import UserNotifications
import RealmSwift
import LocalAuthentication
import CocoaLumberjack

enum AccountSessionState {
    case appStarted
    case willTerminate
    case terminated
    case willSuspend
    case suspended
    case willResume
    case wasSuspended
    case active
}

enum AuthState {
    case notAuthenticated       // No auth complete
    case serverAuthenticated    // Authentication with server done
    case loggedOut              // Server authenticated, app logged out
}

enum UpdateState {
    case gettingMessages
    case gettingRequests
    case gettingStatus
    case idle
}

class AccountSession: NSObject, UNUserNotificationCenterDelegate {

    static let production = true
    private static var theInstance: AccountSession?
    
    @objc var deviceToken: Data?
    private var accountSessionState: AccountSessionState
    private var authState: AuthState
    private var updateState: UpdateState
    var contactManager = ContactManager.instance
    var messageManager = MessageManager()
    var sessionState = SessionState()
    var config = Configurator()
    var firstRun = true
    private var realAccountName: String?
    var accountName: String {
        get {
            return realAccountName!
        }
    }
    var accountLoaded: Bool {
        get {
            return realAccountName != nil
        }
    }
    var serverAuthenticated: Bool {
        get {
            return authState == .serverAuthenticated
        }
    }
    var loggedOut: Bool {
        get {
            return authState == .loggedOut
        }
    }

    @objc static var instance: AccountSession {
        get {
            if let accountSession = AccountSession.theInstance {
                return accountSession
            }
            else {
                AccountSession.theInstance = AccountSession()
                return AccountSession.theInstance!
            }
        }
    }

    private override init() {

        DDLog.add(DDOSLogger.sharedInstance) // Uses os_log
        
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)

        accountSessionState = .terminated
        authState = .notAuthenticated
        updateState = .idle

        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(authComplete(_:)),
                                               name: Notifications.AuthComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getStatusComplete(_:)),
                                               name: Notifications.GetStatusComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getRequestsComplete(_:)),
                                               name: Notifications.GetRequestsComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getMessagesComplete(_:)),
                                               name: Notifications.GetMessagesComplete, object: nil)

    }

    func accountDeleted() {

        config.authenticated = false
        accountSessionState = .terminated
        authState = .notAuthenticated
        updateState = .idle
        realAccountName = nil

    }
    
    func doUpdates() {

        if updateState == .idle && authState == .serverAuthenticated {
            updateState = .gettingMessages
            messageManager.getNewMessages()
        }

    }

    func loadAccount() throws {
        
        let fileManager = FileManager.default
        let documentDirectory = try fileManager.url(for: .documentDirectory,
                                                    in: .userDomainMask,
                                                    appropriateFor:nil,
                                                    create:false)
        let vaultsURL = documentDirectory.appendingPathComponent("PippipVaults")
        let path = vaultsURL.path as NSString
        if !fileManager.fileExists(atPath: path.expandingTildeInPath) {
            try fileManager.createDirectory(at: vaultsURL, withIntermediateDirectories: false, attributes: nil)
        }
        let vaults = try fileManager.contentsOfDirectory(at: vaultsURL,
                                                         includingPropertiesForKeys: nil,
                                                         options: .skipsHiddenFiles)
        if !vaults.isEmpty {
            realAccountName = vaults[0].lastPathComponent
            loadConfig()
        }
        
    }
    
    func loadConfig() {
        
        setRealmConfiguration()
        let realm = try! Realm()
        let config = realm.objects(AccountConfig.self).first
        DDLogDebug("AccountConfig version \(config!.version)")
        
    }
    
    func setDefaultConfig(accountName: String) {
        
        realAccountName = accountName
        setRealmConfiguration()
        let config = AccountConfig()
        let laContext = LAContext()
        var authError: NSError?
        if (laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError)) {
            if laContext.biometryType == .none {
                config.useLocalAuth = false
            }
        }
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(config)
            }
        }
        catch {
            DDLogError("Error writing initial config to database: \(error)")
        }
        
    }
    
    func setRealmConfiguration() {

        var realmConfig = Realm.Configuration()
        realmConfig.fileURL = realmConfig.fileURL?.deletingLastPathComponent()
            .appendingPathComponent("\(realAccountName!).realm")
        realmConfig.schemaVersion = 21
        realmConfig.migrationBlock = { (migration, oldSchemaVersion) in
            if oldSchemaVersion < 15 {
                migration.enumerateObjects(ofType: AccountConfig.className()) { (oldObject, newObject) in
                    newObject!["directoryId"] = oldObject!["nickname"]
                }
            }
        }
        Realm.Configuration.defaultConfiguration = realmConfig
        
    }

    func signOut() {
        
        config.authenticated = false
        authState = .loggedOut
        NotificationCenter.default.post(name: Notifications.SessionEnded, object: nil)
        
    }
    
    @objc func appStarted() {

        accountSessionState = .appStarted

    }

    @objc func willResume() {

        if accountSessionState == .suspended {
            accountSessionState = .willResume
            NotificationCenter.default.post(name: Notifications.AppWillResume, object: nil)
        }

    }

    @objc func resume() {
        
        if accountSessionState == .willResume {
            accountSessionState = .wasSuspended
//            self.doUpdates()
            NotificationCenter.default.post(name: Notifications.AppResumed, object: nil)
        }

    }
    
    @objc func willSuspend() {
        
        if accountSessionState == .active {
            accountSessionState = .willSuspend
            NotificationCenter.default.post(name: Notifications.AppWillSuspend, object: nil)
        }
        
    }
    
    @objc func suspend() {

        if accountSessionState == .willSuspend {
            accountSessionState = .suspended
            NotificationCenter.default.post(name: Notifications.AppSuspended, object: nil)
        }

    }

    @objc func willTerminate() {
        
        accountSessionState = .willTerminate
        NotificationCenter.default.post(name: Notifications.AppWillTerminate, object: nil)

    }
    
    // Notifications
    
    @objc func authComplete(_ notification: Notification) {

        authState = .serverAuthenticated
//        if accountSessionState != .wasSuspended {
            doUpdates()
//        }
        accountSessionState = .active

    }
    
    @objc func getMessagesComplete(_ notification: Notification) {

        if updateState == .gettingMessages && authState == .serverAuthenticated {
            updateState = .gettingRequests
            contactManager.getPendingRequests()
        }
 
    }
 
    @objc func getRequestsComplete(_ notification: Notification) {

        if updateState == .gettingRequests && authState == .serverAuthenticated {
            updateState = .gettingStatus
            contactManager.getRequestStatus()
        }

    }
    
    @objc func getStatusComplete(_ notification: Notification) {

        if updateState == .gettingStatus {
            updateState = .idle
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }

    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        print("Notification received")
        doUpdates()
        completionHandler(.badge)

    }

}
