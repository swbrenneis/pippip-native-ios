//
//  NewAccountCreator.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import CocoaLumberjack
import Promises

class NewAccountCreator: NSObject {

    var passphrase = ""
    var accountName = ""
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
            config.useLocalAuth = biometricsEnabled
            config.uuid = NSUUID().uuidString
            if biometricsEnabled {
                if setKeychainPassphrase(uuid: config.uuid , passphrase: passphrase) {
                    authView.accountCreated(success: true, nil)
                    AccountSession.instance.accountCreated(accountName: accountName)
                } else {
                    authView.accountCreated(success: false, "Unable to store passphrase in keychain")
                }
            } else {
                authView.accountCreated(success: true, nil)
            }
        } catch {
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

        let promise: Promise<NewAccountFinal> = SecommAPI.instance.doPost(request: NewAccountFinish())
        promise.then { response in
            self.accountFinishComplete(response)
        }.catch { error in
            self.accountFinishError(error: error.localizedDescription)
        }
        
    }

    func requestNewAccount() {

        let promise: Promise<NewAccountResponse> = SecommAPI.instance.doPost(request: NewAccountRequest())
        promise.then { response in
            self.accountRequestComplete(response)
        }.catch { error in
            self.accountRequestError(error: error.localizedDescription)
        }
        
    }

    func sessionStarted(sessionResponse: SessionResponse) {
        
        if sessionResponse.error != nil {
            alertPresenter.errorAlert(title: "Session Error", message: sessionResponse.error!)
        }
        else {
            sessionState.sessionId = sessionResponse.sessionId!
            let pem = CKPEMCodec()
            sessionState.serverPublicKey = pem.decodePublicKey(sessionResponse.serverPublicKey!)
            self.requestNewAccount()
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

        do {
            try accountFinal.processResponse()
            accountCreated()
        } catch {
            DDLogError("New account finish error: \(error.localizedDescription)")
            alertPresenter.errorAlert(title: "New Account Error", message: error.localizedDescription)
            authView.accountCreated(success: false, error.localizedDescription)
        }
        
    }

    func accountFinishError(error: String) {
        DDLogError("Account finish error: \(error)")
        authView.accountCreated(success: false, error)
    }

    func accountRequestComplete(_ accountResponse: NewAccountResponse) {

        do {
            try accountResponse.processResponse()
            self.doFinish()
        } catch {
            DDLogError("New account request error: \(error.localizedDescription)")
            self.alertPresenter.errorAlert(title: "New Account Error", message: error.localizedDescription)
            self.authView.accountCreated(success: false, error.localizedDescription)
        }
        
    }

    func accountRequestError(error: String) {
        
        DDLogError("Account request error: \(error)")
        authView.accountCreated(success: false, error)
    
    }

    // Notifications

    @objc func parametersGenerated(_ notification: Notification) {

        SecommAPI.instance.startSession(sessionComplete: { (sessionResponse) in
            self.sessionStarted(sessionResponse: sessionResponse)
        })

    }

}
