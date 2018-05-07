//
//  NewAccountCreator.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

enum Step { case finish, none, request }

class NewAccountCreator: NSObject, RequestProcessProtocol {

    var postPacket: PostPacket?
    var errorDelegate: ErrorDelegate
    var restSession: RESTSession
    var sessionState = SessionState()
    var passphrase = ""
    var step = Step.none

    override init() {

        errorDelegate = NotificationErrorDelegate("New Account Error")
        restSession = ApplicationSingleton.instance().restSession

    }

    func accountCreated() {

        do {
            try storeVault()
            sessionState.authenticated = true
            let accountManager = AccountManager()
            accountManager.setDefaultConfig()
            NotificationCenter.default.post(name: Notifications.Authenticated, object: nil)
        }
        catch {
            var info = [AnyHashable: Any]()
            info["title"] = "New Account Error"
            info["message"] = "Error storing user vault"
            NotificationCenter.default.post(name: Notifications.PresentAlert, object: nil, userInfo: info)
            print("Error storing user vault: \(error)")
        }

    }

    func createAccount(accountName: String, passphrase: String) {

        AccountManager.accountName = accountName
        self.passphrase = passphrase
        let parameterGenerator = ParameterGenerator()
        parameterGenerator.generateParameters(accountName)
        var info = [AnyHashable: Any]()
        info["progress"] = Float(0.25)
        NotificationCenter.default.post(name: Notifications.UpdateProgress, object: nil, userInfo: info)
        restSession.start(self)
        
    }

    func doFinish() {

        step = Step.finish
        postPacket = NewAccountFinish()
        restSession.queuePost(self)

    }

    func postComplete(_ response: [AnyHashable : Any]?) {

        if (response != nil) {
            switch (step) {
            case Step.request:
                if validateResponse(response!) {
                    var info = [AnyHashable: Any]()
                    info["progress"] = Float(0.25)
                    NotificationCenter.default.post(name: Notifications.UpdateProgress, object: nil, userInfo: info)
                    doFinish();
                }
                break;
            case Step.finish:
                if validateFinish(response!) {
                    var info = [AnyHashable: Any]()
                    info["progress"] = Float(0.25)
                    NotificationCenter.default.post(name: Notifications.UpdateProgress, object: nil, userInfo: info)
                    accountCreated();
                }
                break;
            case Step.none:
                break;
            }
            
        }
        
    }
    
    func sessionComplete(_ response: [AnyHashable : Any]?) {

        if (response != nil) {
            guard let sessionId = response!["sessionId"] as? Int32 else {
                errorDelegate.sessionError("Invalid server response, missing session ID")
                return
            }
            guard let serverPublicKeyPEM = response!["serverPublicKey"] as? String else {
                errorDelegate.sessionError("Invalid server response, missing public key")
                return
            }
            sessionState.sessionId = sessionId
            let pem = CKPEMCodec()
            sessionState.serverPublicKey = pem.decodePublicKey(serverPublicKeyPEM)
            step = Step.request
            postPacket = NewAccountRequest()
            restSession.queuePost(self)
        }
        
    }

    func storeVault() throws {

        let fileManager = FileManager.default
        let documentDirectory = try fileManager.url(for: .documentDirectory,
                                                    in: .userDomainMask,
                                                    appropriateFor:nil,
                                                    create:false)
        let vaultsURL = documentDirectory.appendingPathComponent("PippipVaults")
        let vaultURL = vaultsURL.appendingPathComponent(AccountManager.accountName!)
        
        let vault = UserVault()
        let vaultData = try vault.encode(passphrase)
        try vaultData.write(to: vaultURL)

    }

    func validateFinish(_ response: [AnyHashable: Any]) -> Bool {

        let accountFinal = NewAccountFinal()
        return accountFinal.processResponse(response, errorDelegate: errorDelegate)

    }
    
    func validateResponse(_ response: [AnyHashable: Any]) -> Bool {

        let accountResponse = NewAccountResponse()
        return accountResponse.processResponse(response, errorDelegate: errorDelegate)

    }

}
