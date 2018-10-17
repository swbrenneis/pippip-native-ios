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
    var delegate: AuthenticationDelegateProtocol?
    var biometricsEnabled: Bool!

    override init() {
        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(parametersGenerated(_:)),
                                               name: Notifications.ParametersGenerated, object: nil)

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
                let localAuth = LocalAuthenticator()
                localAuth.setKeychainPassphrase(uuid: config.uuid , passphrase: passphrase)
            }
            delegate?.authenticated()
        }
        catch {
            alertPresenter.errorAlert(title: "New Account Error", message: "Unable to store user vault")
            print("Store user vault error: \(error)")
            delegate?.authenticationFailed(reason: error.localizedDescription)
        }

    }

    func createAccount(accountName: String, passphrase: String, biometricsEnabled: Bool) {

        self.passphrase = passphrase
        self.accountName = accountName
        self.biometricsEnabled = biometricsEnabled
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
            do {
                try accountFinal.processResponse()
                self.accountCreated()
            }
            catch {
                print("New account finish error: \(error)")
                self.delegate?.authenticationFailed(reason: error.localizedDescription)
            }
        }
        
    }

    func accountFinishError(error: String) {
        print("Account finish error: \(error)")
        delegate?.authenticationFailed(reason: error)
    }

    func accountRequestComplete(_ accountResponse: NewAccountResponse) {

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try accountResponse.processResponse()
                self.doFinish()
            }
            catch {
                print("New account request error: \(error)")
                self.delegate?.authenticationFailed(reason: error.localizedDescription)
            }
        }
        
    }

    func accountRequestError(error: String) {
        print("Account request error: \(error)")
        delegate?.authenticationFailed(reason: error)
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
    
}
