//
//  SwiftAuthenticator.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/28/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class SwiftAuthenticator: NSObject {

    var alertPresenter = AlertPresenter()
    var secommAPI = SecommAPI()
    var userVault = UserVault()
    var sessionState = SessionState()
    
    func authenticate(accountName: String, passphrase: String) {

        NotificationCenter.default.addObserver(self, selector: #selector(sessionStarted(_:)),
                                               name: Notifications.SessionStarted, object: nil)
        if openVault(accountName: accountName, passphrase: passphrase) {
            var info = [AnyHashable: Any]()
            info["progress"] = 0.2
            NotificationCenter.default.post(name: Notifications.UpdateProgress, object: nil, userInfo: info)
            secommAPI.startSession()
        }
        else {
            alertPresenter.errorAlert(title: "Sign In Error", message: "Invalid Passphrase")
        }

    }

    func doAuthorized() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(authorizedComplete(_:)),
                                               name: Notifications.PostComplete, object: nil)
        let authorized = ServerAuthorized()
        secommAPI.doPost(responseType: ClientAuthorized.self, request: authorized)

    }

    func doChallenge() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(authChallengeComplete(_:)),
                                               name: Notifications.PostComplete, object: nil)
        let authChallenge = ClientAuthChallenge()
        secommAPI.doPost(responseType: ServerAuthChallenge.self, request: authChallenge)

    }

    func logout() {

        let logout = Logout()
        secommAPI.doPost(responseType: NullResponse.self, request: logout)

    }

    func openVault(accountName: String, passphrase: String) -> Bool {

        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var vaultUrl = paths[0]
        vaultUrl.appendPathComponent("PippipVaults", isDirectory: true)
        vaultUrl.appendPathComponent(accountName)
        do {
            let vaultData = try Data(contentsOf: vaultUrl)
            try userVault.decode(vaultData, passphrase: passphrase)
            return true
        }
        catch {
            print("Unable to open vault file: \(error)")
        }
        return false

    }

    func requestAuth() {

        NotificationCenter.default.addObserver(self, selector: #selector(authRequestComplete(_:)),
                                               name: Notifications.PostComplete, object: nil)
        let authRequest = AuthenticationRequest()
        secommAPI.doPost(responseType: AuthenticationResponse.self, request: authRequest)

    }

    // Notifications

    @objc func authChallengeComplete(_ notification: Notification) {
        
        guard let authChallenge = notification.object as? ServerAuthChallenge else { return }
        NotificationCenter.default.removeObserver(self, name: Notifications.PostComplete, object: nil)
        var info = [AnyHashable: Any]()
        info["progress"] = 0.8
        NotificationCenter.default.post(name: Notifications.UpdateProgress, object: nil, userInfo: info)

        DispatchQueue.global().async {
            do {
                try authChallenge.processResponse()
                self.doAuthorized()
            }
            catch {
                print("Authentication challenge error: \(error)")
            }
        }
        
    }

    @objc func authorizedComplete(_ notification: Notification) {
        
        guard let authorized = notification.object as? ClientAuthorized else { return }
        NotificationCenter.default.removeObserver(self, name: Notifications.PostComplete, object: nil)
        var info = [AnyHashable: Any]()
        info["progress"] = 1.0
        NotificationCenter.default.post(name: Notifications.UpdateProgress, object: nil, userInfo: info)

        do {
            try authorized.processResponse()
            sessionState.authenticated = true
            NotificationCenter.default.post(name: Notifications.Authenticated, object: nil)
        }
        catch {
            print("Authentication request error: \(error)")
        }
    }

    @objc func authRequestComplete(_ notification: Notification) {

        guard let authResponse = notification.object as? AuthenticationResponse else { return }
        NotificationCenter.default.removeObserver(self, name: Notifications.PostComplete, object: nil)
        var info = [AnyHashable: Any]()
        info["progress"] = 0.6
        NotificationCenter.default.post(name: Notifications.UpdateProgress, object: nil, userInfo: info)

        DispatchQueue.global().async {
            do {
                try authResponse.processResponse()
                self.doChallenge()
            }
            catch {
                print("Authentication request error: \(error)")
            }
        }

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
            info["progress"] = 0.4
            NotificationCenter.default.post(name: Notifications.UpdateProgress, object: nil, userInfo: info)
            DispatchQueue.global().async {
                self.requestAuth()
            }
        }
        
    }
    
}
