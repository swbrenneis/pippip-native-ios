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

class AccountSession: NSObject, UNUserNotificationCenterDelegate {

    static let production = true
    static var firstRun = true
    static var accountName: String?
    
    @objc var deviceToken: Data?
    var sessionActive = false
    var suspended = false
    var contactManager = ContactManager()
    var messageManager = MessageManager()
    var sessionState = SessionState()

    override init() {
        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(newSession(_:)),
                                               name: Notifications.NewSession, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionEnded(_:)),
                                               name: Notifications.SessionEnded, object: nil)

    }

    func doUpdates() {

        if !suspended {
            NotificationCenter.default.addObserver(self, selector: #selector(getMessagesComplete(_:)),
                                                   name: Notifications.GetMessagesComplete, object: nil)
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
            AccountSession.accountName = vaults[0].lastPathComponent
        }
        
    }
    
    func loadConfig() {
        
        setRealmConfiguration()
        let realm = try! Realm()
        let config = realm.objects(AccountConfig.self).first
        print("AccountConfig version \(config!.version)")
        
    }
    
    func setDefaultConfig() {
        
        setRealmConfiguration()
        let config = AccountConfig()
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(config)
            }
        }
        catch {
            print("Error writing initial config to database: \(error)")
        }
        
    }
    
    func setRealmConfiguration() {

        var realmConfig = Realm.Configuration()
        realmConfig.fileURL = realmConfig.fileURL?.deletingLastPathComponent()
            .appendingPathComponent("\(AccountSession.accountName!).realm")
        realmConfig.schemaVersion = 16
        realmConfig.migrationBlock = { (migration, oldSchemaVersion) in
            // Schema version 13 is Realm Swift
/*            if oldSchemaVersion < 13 {
                migration.enumerateObjects(ofType: DatabaseContact.className()) { (oldObject, newObject) in
                    newObject!["contactId"] = oldObject!["contactId"]
                    newObject!["encoded"] = oldObject!["encoded"]
                }
                migration.enumerateObjects(ofType: DatabaseContactRequest.className()) { (oldObject, newObject) in
                    newObject!["publicId"] = oldObject!["publicId"]
                    newObject!["nickname"] = oldObject!["nickname"]
                }
                migration.enumerateObjects(ofType: DatabaseMessage.className()) { (oldObject, newObject) in
                    newObject!["version"] = oldObject!["version"]
                    newObject!["contactId"] = oldObject!["contactId"]
                    newObject!["messageId"] = oldObject!["messageId"]
                    newObject!["ciphertext"] = oldObject!["message"]
                    newObject!["keyIndex"] = oldObject!["keyIndex"]
                    newObject!["sequence"] = oldObject!["sequence"]
                    newObject!["timestamp"] = oldObject!["timestamp"]
                    newObject!["cleartext"] = oldObject!["cleartext"]
                    newObject!["read"] = oldObject!["read"]
                    newObject!["acknowledged"] = oldObject!["acknowledged"]
                    newObject!["originating"] = oldObject!["sent"]
                    newObject!["compressed"] = oldObject!["compressed"]
//                    newObject!["failed"] = oldObject!["failed"]
                }
                migration.enumerateObjects(ofType: AccountConfig.className()) { (oldObject, newObject) in
                    newObject!["version"] = oldObject!["version"]
                    newObject!["nickname"] = oldObject!["nickname"]
                    newObject!["contactPolicy"] = oldObject!["contactPolicy"]
                    newObject!["currentMessageId"] = oldObject!["messageId"]
                    newObject!["currentContactId"] = oldObject!["contactId"]
                    newObject!["whitelist"] = oldObject!["whitelist"]
                    newObject!["storeCleartextMessages"] = oldObject!["cleartextMessages"]
                    newObject!["useLocalAuth"] = oldObject!["localAuth"]
                }
            } */
            if oldSchemaVersion < 15 {
                migration.enumerateObjects(ofType: AccountConfig.className()) { (oldObject, newObject) in
                    newObject!["directoryId"] = oldObject!["nickname"]
                }
                migration.enumerateObjects(ofType: DatabaseContactRequest.className()) { (oldObject, newObject) in
                    newObject!["directoryId"] = oldObject!["nickname"]
                }
            }
        }
        Realm.Configuration.defaultConfiguration = realmConfig
        
    }

    // Notifications
    
    @objc func resume() {
        
        if suspended  && sessionState.authenticated {
            suspended = false
            NotificationCenter.default.post(name: Notifications.AppResumed, object: nil)
            DispatchQueue.main.async {
                if UIApplication.shared.applicationIconBadgeNumber > 0 {
                    self.doUpdates()
                }
            }
        }

    }

    @objc func suspend() {
        
        suspended = true
        NotificationCenter.default.post(name: Notifications.AppSuspended, object: nil)

    }

    @objc func getMessagesComplete(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.GetMessagesComplete, object: nil)
        contactManager.getPendingRequests()
        contactManager.getRequestStatus(retry: false, publicId: nil)
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }

    }
    
    @objc func newSession(_ notification: Notification) {
        sessionActive = true
        doUpdates()
    }

    @objc func sessionEnded(_ notification: Notification) {

        sessionActive = false
        //contactManager.clearContacts()
        //ConversationCache.clearCache()

    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        print("Notification received")
        if sessionActive {
            doUpdates()
        }
        completionHandler(.badge)

    }

}
