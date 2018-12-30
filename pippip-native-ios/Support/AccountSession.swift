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
    case initializing
    case appStarted
    case active
    case willSuspend
    case suspended
    case willResume
}

enum AuthState {
    case notAuthenticated       // No auth complete
    case serverAuthenticated    // Authentication with server done
    case reauthenticating       // Server send needsAuth
    case loggedOut              // Server authenticated, app logged out
}

enum UpdateState {
    case gettingMessages
    case gettingRequests
    case gettingStatus
    case idle
}

@objc class AccountSession: NSObject, UNUserNotificationCenterDelegate {

    static let production = true
    private static var theInstance: AccountSession?
    
    @objc var deviceToken: Data?
    private var accountSessionState: AccountSessionState
    private var authState: AuthState
    private var updateState: UpdateState
    private var didUpdate = false                   // Update after suspend
//    var messageManager = MessageManager()
//    var sessionState = SessionState.instance
//    var config = Configurator()
    private var firstResume = true
    private var realAccountName: String?
    var accountName: String {
        get {
            return realAccountName!
        }
        set {
            realAccountName = newValue
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
    var needsServerAuth: Bool {
        get {
            return authState == .notAuthenticated
        }
    }
    var loggedOut: Bool {
        get {
            return authState == .loggedOut
        }
    }
    var newAccount: Bool {
        get {
            return realAccountName == nil
        }
    }
    var starting: Bool {
        get {
            return accountSessionState == .appStarted
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

        accountSessionState = .initializing
        authState = .notAuthenticated
        updateState = .idle

        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(getStatusComplete(_:)),
                                               name: Notifications.GetStatusComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getMessagesComplete(_:)),
                                               name: Notifications.GetMessagesComplete, object: nil)

    }

    func accountCreated(accountName: String) {

        realAccountName = accountName
        accountSessionState = .active
        authState = .serverAuthenticated

    }

    func accountDeleted() {

//        config.authenticated = false
        accountSessionState = .appStarted
        authState = .notAuthenticated
        updateState = .idle
        realAccountName = nil
        NotificationCenter.default.post(name: Notifications.ResetControllers, object: nil)

    }
    
    func authenticated() {
        
        authState = .serverAuthenticated
        accountSessionState = .active
        doUpdates()

    }

    func autoAcknowledge(requests: [ContactRequest]) {
        
        for contactRequest in requests {
            guard let puid = contactRequest.publicId else { continue }
            if ContactsModel.instance.whitelistIdExists(publicId: puid) {
                AutoAcknowledgement().acknowledge(publicId: puid)
            }
        }
        
    }
    
    // DEBUG ONLY!
    private func deleteAccount(name: String) {

        do {
            let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
            let realmURLs = [
                realmURL,
                realmURL.appendingPathExtension("lock"),
                realmURL.appendingPathExtension("note"),
                realmURL.appendingPathExtension("management")
            ]
            for URL in realmURLs {
                try FileManager.default.removeItem(at: URL)
            }
        }
        catch {
            print("No Realm files present")
        }
        
        do {
            let docsURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let docURL = docsURLs[0]
            let vaultsURL = docURL.appendingPathComponent("PippipVaults", isDirectory: true)
            let vaultUrl = vaultsURL.appendingPathComponent(name)
            try FileManager.default.removeItem(at: vaultUrl)
        }
        catch {
            print("no vault file present")
        }

    }
    
    func doUpdates() {

        if updateState == .idle && authState != .notAuthenticated {
            updateState = .gettingMessages
            let messageManager = MessageManager()
            messageManager.getNewMessages()
        }

    }

    func getRequestsComplete() {
        
        if updateState == .gettingRequests && authState == .serverAuthenticated {
            updateState = .gettingStatus
            let contactManager = ContactManager()
            contactManager.getRequestStatus()
        }
        
    }
    
    @objc func loadAccount() {
        
        do {
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
                // Debug delete bad accounts here
                //deleteAccount(name: vaults[0].lastPathComponent)
                realAccountName = vaults[0].lastPathComponent
                loadConfig()
            }
        }
        catch {
            DDLogError("Unable to load account: \(error.localizedDescription)")
        }
        
    }
    
    func loadConfig() {
        
        setRealmConfiguration()
        let realm = try! Realm()
        let config = realm.objects(AccountConfig.self).first
        DDLogDebug("AccountConfig version \(config!.version)")
        
    }

    func needsAuth() {
        
        updateState = .idle
        authState = .reauthenticating

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
        realmConfig.schemaVersion = 22
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
        
//        config.authenticated = false
        authState = .loggedOut
        NotificationCenter.default.post(name: Notifications.SessionEnded, object: nil)
        
    }

    // App lifecycle
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
            accountSessionState = .active
            NotificationCenter.default.post(name: Notifications.AppResumed, object: nil)
            DispatchQueue.main.async {
                if UIApplication.shared.applicationIconBadgeNumber > 0 {
                    self.doUpdates()
                }
            }
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
            didUpdate = false
            firstResume = true
            NotificationCenter.default.post(name: Notifications.AppSuspended, object: nil)
        }

    }

    @objc func willTerminate() {
        
        NotificationCenter.default.post(name: Notifications.AppWillTerminate, object: nil)

    }
    
    // Notifications

    @objc func getMessagesComplete(_ notification: Notification) {

        if updateState == .gettingMessages && authState == .serverAuthenticated {
            updateState = .gettingRequests
            do {
                let contactManager = ContactManager()
                try contactManager.getPendingRequests(
                    onResponse: { response -> Void in
                        guard let requests = response.requests else { return }
                        DDLogInfo("\(requests.count) pending requests returned")
                        if requests.count > 0 {
                            var contactRequests = [ContactRequest]()
                            for pair in requests {
                                if let contactRequest = ContactRequest(request: pair) {
                                    contactRequests.append(contactRequest)
                                }
                            }
                            ContactsModel.instance.addRequests(requests: contactRequests)
                            if Configurator().contactPolicy == Configurator.whitelistPolicy {
                                self.autoAcknowledge(requests: contactRequests)
                            }
                            NotificationCenter.default.post(name: Notifications.SetContactBadge, object: nil)
                        }
                        else {
                            ContactsModel.instance.clearRequests()
                        }
                        self.getRequestsComplete()
                },
                    onError: { error in
                        DDLogError("Get pending requests error: \(error)")
                        self.getRequestsComplete()
                })
            }
            catch {
                DDLogError("Get pending requests error: \(error.localizedDescription)")
                self.getRequestsComplete()
            }
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
        didUpdate = true
        doUpdates()
        completionHandler(.badge)

    }

}
