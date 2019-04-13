//
//  SwiftAuthenticator.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/28/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import CocoaLumberjack
import Promises

class ServerAuthenticator: NSObject {

    var alertPresenter = AlertPresenter()
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
            SecommAPI.instance.startSession(sessionComplete: { (sessionResponse) in
                self.sessionStarted(sessionResponse: sessionResponse)
            })
        }
        else {
            authView?.authenticated(success: false, "InvalidPassphrase")
        }

    }

    func doAuthorized() {

        let promise : Promise<ClientAuthorized> = SecommAPI.instance.doPost(request: ServerAuthorized())
        promise.then { (response) in
            self.authorizedComplete(response)
        }.catch { error in
            self.authorizedError(error: error.localizedDescription)
        }
//        SecommAPI.instance.queuePost(delegate: APIResponseDelegate(request: ServerAuthorized(),
//                                                                   postType: .authenticator,
//                                                                   responseComplete: self.authorizedComplete,
//                                                                   responseError: self.authorizedError))

    }

    func doChallenge() {

        let promise : Promise<ServerAuthChallenge> = SecommAPI.instance.doPost(request: ClientAuthChallenge())
        promise.then { (response) in
            self.authChallengeComplete(response)
            }.catch { error in
                self.authChallengeError(error: error.localizedDescription)
        }
//        SecommAPI.instance.queuePost(delegate: APIResponseDelegate(request: ClientAuthChallenge(),
//                                                                   postType: .authenticator,
//                                                                  responseComplete: self.authChallengeComplete,
//                                                                  responseError: self.authChallengeError))
        
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

        let promise : Promise<AuthenticationResponse> = SecommAPI.instance.doPost(request: AuthenticationRequest())
        promise.then { (response) in
            self.authRequestComplete(response)
        }.catch { error in
            self.authRequestError(error: error.localizedDescription)
        }
//        SecommAPI.instance.queuePost(delegate: APIResponseDelegate(request: AuthenticationRequest(),
//                                                                   postType: .authenticator,
//                                                                   responseComplete: self.authRequestComplete,
//                                                                   responseError: self.authRequestError))
        
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
        
        do {
            try authChallenge.processResponse()
            doAuthorized()
        } catch {
            DDLogError("Authentication challenge error: \(error.localizedDescription)")
            alertPresenter.errorAlert(title: "Sign In Error", message: error.localizedDescription)
            authView?.authenticated(success: false, error.localizedDescription)
        }

    }

    func authChallengeError(error: String) {

        DDLogError("Authentication challenge error: \(error)")
        authView?.authenticated(success: false, Strings.errorAuthenticationFailed)
        sessionState.reauth = false

    }
    
    func authorizedComplete(_ authorized: ClientAuthorized) {
        
        do {
            try authorized.processResponse()
//            let config = Configurator()
//            config.authenticated = true
            sessionState.sessionId = authorized.sessionId!
            sessionState.authToken = authorized.authToken!
            AccountSession.instance.authenticated()
            authView?.authenticated(success: true, nil)
        } catch {
            authView?.authenticated(success: false, error.localizedDescription)
            DDLogError("Client authorization error : \(error.localizedDescription)")
            alertPresenter.errorAlert(title: "Sign In Error", message: Strings.errorAuthenticationFailed)
        }

    }

    func authorizedError(error: String) {

        DDLogError("Authorization error: \(error)")
        authView?.authenticated(success: false, Strings.errorAuthenticationFailed)
        sessionState.reauth = false

    }

    func authRequestComplete(_ authResponse: AuthenticationResponse) {

        do {
            try authResponse.processResponse()
            doChallenge()
        } catch {
            DDLogError("Authentication request error: \(error.localizedDescription)")
            authView?.authenticated(success: false, error.localizedDescription)
            alertPresenter.errorAlert(title: "Sign In Error", message: error.localizedDescription)
        }

    }

    func authRequestError(error: String) {
        
        DDLogError("Authentication request error: \(error)")
        authView?.authenticated(success: false, Strings.errorAuthenticationFailed)
        sessionState.reauth = false

    }

}
