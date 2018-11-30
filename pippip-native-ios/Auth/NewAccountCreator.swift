//
//  NewAccountCreator.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import CocoaLumberjack

class NewAccountCreator: NSObject, SessionObserverProtocol {

    var passphrase = ""
    var accountName = ""
    var secommAPI = SecommAPI()
    var alertPresenter = AlertPresenter()
    var sessionState = SessionState()
    var biometricsEnabled: Bool!
    var authView: AuthView

    init(authView: AuthView) {

        self.authView = authView
        
        super.init()

    }

    func accountCreated() {

        do {
            try storeVault()
            AccountSession.instance.setDefaultConfig(accountName: accountName)
            let config = Configurator()
            config.authenticated = true
            config.useLocalAuth = biometricsEnabled
            config.uuid = NSUUID().uuidString
            if biometricsEnabled {
                if setKeychainPassphrase(uuid: config.uuid , passphrase: passphrase) {
                    authView.accountCreated(success: true, nil)
                    AccountSession.instance.accountCreated(accountName: accountName)
                }
                else {
                    authView.accountCreated(success: false, "Unable to store passphrase in keychain")
                }
            }
        }
        catch {
            DDLogError("Store user vault error: \(error.localizedDescription)")
            authView.accountCreated(success: false, "Unable to store user vault")
        }

    }

    func createAccount(accountName: String, passphrase: String, biometricsEnabled: Bool) {

        self.passphrase = passphrase
        self.accountName = accountName
        self.biometricsEnabled = biometricsEnabled
        NotificationCenter.default.addObserver(self, selector: #selector(parametersGenerated(_:)),
                                               name: Notifications.ParametersGenerated, object: nil)
        
        DispatchQueue.global().async {
            let parameterGenerator = ParameterGenerator()
            parameterGenerator.generateParameters(accountName)
        }

    }

    func doFinish() {

        secommAPI.queuePost(delegate: APIResponseDelegate(request: NewAccountFinish(),
                                                          responseComplete: self.accountFinishComplete,
                                                          responseError: self.accountFinishError))
        
    }

    func requestNewAccount() {

        secommAPI.queuePost(delegate: APIResponseDelegate(request: NewAccountRequest(),
                                                          responseComplete: self.accountRequestComplete,
                                                          responseError: self.accountRequestError))
        
    }

    func sessionStarted(sessionResponse: SessionResponse) {
        
        if sessionResponse.error != nil {
            alertPresenter.errorAlert(title: "Session Error", message: sessionResponse.error!)
        }
        else {
            sessionState.sessionId = sessionResponse.sessionId!
            let pem = CKPEMCodec()
            sessionState.serverPublicKey = pem.decodePublicKey(sessionResponse.serverPublicKey!)
            var info = [AnyHashable: Any]()
            info["progress"] = 0.5
            DispatchQueue.global().async {
                self.requestNewAccount()
            }
        }
        
    }
    
    func setKeychainPassphrase(uuid: String, passphrase: String) -> Bool {
        
        let keychain = Keychain(service: Keychain.PIPPIP_TOKEN_SERVICE)
        do {
            try keychain.accessibility(protection: .passcodeSetThisDeviceOnly, createFlag: .userPresence)
                .set(passphrase: passphrase, key: uuid)
            return true
        }
        catch {
            DDLogError("Error adding passphrase to keychain: \(error)")
            self.alertPresenter.errorAlert(title: "Authentication Error", message: "Unable to store passphrase")
            return false
        }
        
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

        DispatchQueue.global(qos: .userInitiated).async {
            if let error = accountFinal.processResponse() {
                DDLogError("New account finish error: \(error)")
                self.alertPresenter.errorAlert(title: "New Account Error", message: error)
                self.authView.accountCreated(success: false, error)
            }
            else {
                self.accountCreated()
            }
        }
        
    }

    func accountFinishError(error: String) {
        DDLogError("Account finish error: \(error)")
        authView.accountCreated(success: false, error)
    }

    func accountRequestComplete(_ accountResponse: NewAccountResponse) {

        DispatchQueue.global(qos: .userInitiated).async {
            if let error = accountResponse.processResponse() {
                DDLogError("New account request error: \(error)")
                self.alertPresenter.errorAlert(title: "New Account Error", message: error)
                self.authView.accountCreated(success: false, error)
            }
            else {
                self.doFinish()
            }
        }
        
    }

    func accountRequestError(error: String) {
        
        DDLogError("Account request error: \(error)")
        authView.accountCreated(success: false, error)
    
    }

    // Notifications

    @objc func parametersGenerated(_ notification: Notification) {

        secommAPI.startSession(sessionObserver: self)

    }

}
