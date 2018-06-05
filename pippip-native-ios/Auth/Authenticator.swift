//
//  SwiftAuthenticator.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/28/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class Authenticator: NSObject {

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

        secommAPI.doPost(observer: PostObserver(request: ServerAuthorized(),
                                                postComplete: self.authorizedComplete,
                                                postError: self.authorizedError))

    }

    func doChallenge() {

        secommAPI.doPost(observer: PostObserver(request: ClientAuthChallenge(),
                                                postComplete: self.authChallengeComplete,
                                                postError: self.authChallengeError))
        
    }

    @objc func logout() {

        secommAPI.doPost(observer: PostObserver(request: Logout(),
                                                postComplete: self.logoutComplete,
                                                postError: self.logoutError))
        sessionState.authenticated = false
        DispatchQueue.global().async {
            NotificationCenter.default.post(name: Notifications.SessionEnded, object: nil)
        }

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
        
        secommAPI.doPost(observer: PostObserver(request: AuthenticationRequest(),
                                                postComplete: self.authRequestComplete,
                                                postError: self.authRequestError))
        
    }

    // Observer functions

    func authChallengeComplete(_ authChallenge: ServerAuthChallenge) {
        
        var info = [AnyHashable: Any]()
        info["progress"] = 0.8
        NotificationCenter.default.post(name: Notifications.UpdateProgress, object: nil, userInfo: info)

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try authChallenge.processResponse()
                self.doAuthorized()
            }
            catch {
                print("Authentication challenge error: \(error)")
            }
        }
        
    }

    func authChallengeError(_ error: Error) {
        print("Authentication challenge error: \(error)")
    }
    
    func authorizedComplete(_ authorized: ClientAuthorized) {
        
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

    func authorizedError(_ error: Error) {
        print("Authorization error: \(error)")
    }

    func authRequestComplete(_ authResponse: AuthenticationResponse) {

        var info = [AnyHashable: Any]()
        info["progress"] = 0.6
        NotificationCenter.default.post(name: Notifications.UpdateProgress, object: nil, userInfo: info)

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try authResponse.processResponse()
                self.doChallenge()
            }
            catch {
                print("Authentication request error: \(error)")
            }
        }

    }

    func authRequestError(_ error: Error) {
        print("Authentication request error: \(error)")
    }

    func logoutComplete(_ response: NullResponse) {
        // Nothing to do here
    }

    func logoutError(_ error: Error) {
        // Nothing to do here
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
