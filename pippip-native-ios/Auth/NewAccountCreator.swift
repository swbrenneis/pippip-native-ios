//
//  NewAccountCreator.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class NewAccountCreator: NSObject {

    var passphrase = ""
    var accountName = ""
    var secommAPI = SecommAPI()
    var alertPresenter = AlertPresenter()
    var sessionState = SessionState()

    override init() {
        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(parametersGenerated(_:)),
                                               name: Notifications.ParametersGenerated, object: nil)

    }

    func accountCreated() {

        do {
            try storeVault()
            let accountManager = AccountManager()
            accountManager.setDefaultConfig()
            sessionState.authenticated = true
            NotificationCenter.default.post(name: Notifications.Authenticated, object: nil)
        }
        catch {
            alertPresenter.errorAlert(title: "New Account Error", message: "Unable to store user vault")
            print("Store user vault error: \(error)")
        }

    }

    func createAccount(accountName: String, passphrase: String) {

        AccountManager.accountName(accountName)
        self.passphrase = passphrase
        self.accountName = accountName
        DispatchQueue.global().async {
            let parameterGenerator = ParameterGenerator()
            parameterGenerator.generateParameters(accountName)
        }
        var info = [AnyHashable: Any]()
        info["progress"] = 0.25
        NotificationCenter.default.post(name: Notifications.UpdateProgress, object: nil, userInfo: info)
        //secommAPI.startSession()

    }

    func doFinish() {

        secommAPI.doPost(observer: PostObserver(request: NewAccountFinish(),
                                                postComplete: self.accountFinishComplete,
                                                postError: self.accountFinishError))
        
    }

    func requestNewAccount() {

        secommAPI.doPost(observer: PostObserver(request: NewAccountRequest(),
                                                postComplete: self.accountRequestComplete,
                                                postError: self.accountRequestError))
        
    }

    func storeVault() throws {

        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var vaultUrl = paths[0]
        vaultUrl.appendPathComponent("PippipVaults", isDirectory: true)

        let vault = UserVault()
        let vaultData = try vault.encode(passphrase)
        try FileManager.default.createDirectory(at: vaultUrl, withIntermediateDirectories: true, attributes: nil)

        vaultUrl.appendPathComponent(accountName)
        try vaultData.write(to: vaultUrl, options: .atomicWrite)

    }

    // Observer functions

    func accountFinishComplete(_ accountFinal: NewAccountFinal) {

        var info = [AnyHashable: Any]()
        info["progress"] = 1.0
        NotificationCenter.default.post(name: Notifications.UpdateProgress, object: nil, userInfo: info)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try accountFinal.processResponse()
                self.accountCreated()
            }
            catch {
                print("New account finish error: \(error)")
            }
        }
        
    }

    func accountFinishError(_ error: Error) {
        print("Account finish error: \(error)")
    }

    func accountRequestComplete(_ accountResponse: NewAccountResponse) {

        var info = [AnyHashable: Any]()
        info["progress"] = 0.75
        NotificationCenter.default.post(name: Notifications.UpdateProgress, object: nil, userInfo: info)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try accountResponse.processResponse()
                self.doFinish()
            }
            catch {
                print("New account request error: \(error)")
            }
        }
        
    }

    func accountRequestError(_ error: Error) {
        print("Account request error: \(error)")
    }

    // Notifications

    @objc func parametersGenerated(_ notification: Notification) {

        NotificationCenter.default.addObserver(self, selector: #selector(sessionStarted(_:)),
                                               name: Notifications.SessionStarted, object: nil)
        secommAPI.startSession()

    }

    @objc func sessionStarted(_ notification: Notification) {
        
        NotificationCenter.default.removeObserver(self, name: Notifications.SessionStarted, object: nil)
        guard let sessionResponse = notification.object as? SessionResponse else { return }
        if sessionResponse.error != nil {
            alertPresenter.errorAlert(title: "Session Error", message: sessionResponse.error!)
        }
        else {
            LocalAuthenticator.sessionTTL = sessionResponse.sessionTTL!
            sessionState.sessionId = sessionResponse.sessionId!
            let pem = CKPEMCodec()
            sessionState.serverPublicKey = pem.decodePublicKey(sessionResponse.serverPublicKey!)
            var info = [AnyHashable: Any]()
            info["progress"] = 0.5
            NotificationCenter.default.post(name: Notifications.UpdateProgress, object: nil, userInfo: info)
            DispatchQueue.global().async {
                self.requestNewAccount()
            }
        }
        
    }
    
}
