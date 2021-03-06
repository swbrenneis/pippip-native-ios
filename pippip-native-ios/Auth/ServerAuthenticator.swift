//
//  SwiftAuthenticator.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/28/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import CocoaLumberjack

class ServerAuthenticator: NSObject, SessionObserverProtocol {

    var alertPresenter = AlertPresenter()
    var secommAPI = SecommAPI()
    var userVault = UserVault()
    var sessionState = SessionState()
    var authView: AuthView?
    var reauth = false

    init(authView: AuthView?) {
    
        self.authView = authView
        
        super.init()
        
    }

    func authenticate(passphrase: String) {

        if openVault(passphrase: passphrase) {
            secommAPI.startSession(sessionObserver: self)
        }
        else {
            authView?.authenticated(success: false, "InvalidPassphrase")
        }

    }

    func reauthenticate() {

        reauth = true
        secommAPI.startSession(sessionObserver: self)

    }

    func doAuthorized() {

        secommAPI.queuePost(delegate: APIResponseDelegate(request: ServerAuthorized(),
                                                          responseComplete: self.authorizedComplete,
                                                          responseError: self.authorizedError))

    }

    func doChallenge() {

        secommAPI.queuePost(delegate: APIResponseDelegate(request: ClientAuthChallenge(),
                                                          responseComplete: self.authChallengeComplete,
                                                          responseError: self.authChallengeError))
        
    }

    func openVault(passphrase: String) -> Bool {

        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var vaultUrl = paths[0]
        vaultUrl.appendPathComponent("PippipVaults", isDirectory: true)
        vaultUrl.appendPathComponent(AccountSession.instance.accountName)
        do {
            let vaultData = try Data(contentsOf: vaultUrl)
            try userVault.decode(vaultData, passphrase: passphrase)
            return true
        }
        catch {
            DDLogError("Unable to open vault file: \(error)")
            return false
        }

    }

    func requestAuth() {

        secommAPI.queuePost(delegate: APIResponseDelegate(request: AuthenticationRequest(),
                                                          responseComplete: self.authRequestComplete,
                                                          responseError: self.authRequestError))
        
    }

    func sessionStarted(sessionResponse: SessionResponse) {
        
        if sessionResponse.error != nil {
            authView?.authenticated(success: false, sessionResponse.error!)
            sessionState.reauth = false
        }
        else {
            sessionState.sessionId = sessionResponse.sessionId!
            let pem = CKPEMCodec()
            sessionState.serverPublicKey = pem.decodePublicKey(sessionResponse.serverPublicKey!)
            DispatchQueue.global().async {
                self.requestAuth()
            }
        }
        
    }
    
    // Observer functions

    func authChallengeComplete(_ authChallenge: ServerAuthChallenge) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let error = authChallenge.processResponse() {
                DDLogError("Authentication challenge error: \(error)")
                self.alertPresenter.errorAlert(title: "Sign In Error", message: error)
                self.authView?.authenticated(success: false, error)
            }
            else {
                self.doAuthorized()
            }
        }
        sessionState.reauth = false

    }

    func authChallengeError(error: String) {

        DDLogError("Authentication challenge error: \(error)")
        authView?.authenticated(success: false, error)
        sessionState.reauth = false

    }
    
    func authorizedComplete(_ authorized: ClientAuthorized) {
        
        if reauth {
            reauthComplete(authorized)
        }
        else if let error = authorized.processResponse() {
            authView?.authenticated(success: false, error)
            DDLogError("Client authorization error : \(error)")
            self.alertPresenter.errorAlert(title: "Sign In Error", message: error)
        }
        else {
            let config = Configurator()
            config.authenticated = true
            sessionState.sessionId = authorized.sessionId!
            sessionState.authToken = authorized.authToken!
            AccountSession.instance.authenticated()
            authView?.authenticated(success: true, nil)
        }
        sessionState.reauth = false

    }

    func authorizedError(error: String) {

        DDLogError("Authorization error: \(error)")
        authView?.authenticated(success: false, error)
        sessionState.reauth = false

    }

    func authRequestComplete(_ authResponse: AuthenticationResponse) {

        DispatchQueue.global(qos: .userInitiated).async {
            if let error = authResponse.processResponse() {
                DDLogError("Authentication request error: \(error)")
                self.authView?.authenticated(success: false, error)
                self.alertPresenter.errorAlert(title: "Sign In Error", message: error)
           }
            else {
                self.doChallenge()
            }
 
        }
        sessionState.reauth = false

    }

    func authRequestError(error: String) {
        
        DDLogError("Authentication request error: \(error)")
        authView?.authenticated(success: false, error)
        sessionState.reauth = false

    }

    private func reauthComplete(_ authorized: ClientAuthorized) {
        
        if let error = authorized.processResponse() {
            DDLogError("Client authorization error : \(error)")
        }
        else {
            let config = Configurator()
            config.authenticated = true
            sessionState.sessionId = authorized.sessionId!
            sessionState.authToken = authorized.authToken!
            AccountSession.instance.authenticated()
            NotificationCenter.default.post(name: Notifications.ReauthComplete, object: nil)
        }
        sessionState.reauth = false

    }

}
