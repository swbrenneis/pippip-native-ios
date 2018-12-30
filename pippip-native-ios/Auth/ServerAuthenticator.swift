//
//  SwiftAuthenticator.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/28/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import CocoaLumberjack

class ServerAuthenticator: NSObject, AuthContextProtocol {
    
    var alertPresenter = AlertPresenter()
    var authView: AuthView?
    var currentStep: AuthStepProtocol?
    
    init(authView: AuthView?) {
        
        self.authView = authView
        
        super.init()
        
    }
    
    func authenticate(passphrase: String) {
        
        if openVault(passphrase: passphrase) {
            currentStep = StartSessionStep()
            currentStep?.step(authContext: self)
        }
        else {
            authView?.hideToastActivity()
            alertPresenter.errorAlert(title: "Authentication Error", message: "Invalid passphrase")
        }
        
    }

    func authComplete(success: Bool) {

        DispatchQueue.main.async {
            self.authView?.hideToastActivity()
            if success {
                AccountSession.instance.authenticated()
                self.authView?.dismiss()
            }
            // TODO: Get rid of this
            NotificationCenter.default.post(name: Notifications.AuthComplete, object: success)
        }

    }
    
    func nextStep(step: AuthStepProtocol) {

        currentStep = step
        currentStep?.step(authContext: self)
        
    }

    func openVault(passphrase: String) -> Bool {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var vaultUrl = paths[0]
        vaultUrl.appendPathComponent("PippipVaults", isDirectory: true)
        vaultUrl.appendPathComponent(AccountSession.instance.accountName)
        do {
            let vaultData = try Data(contentsOf: vaultUrl)
            let userVault = UserVault()
            try userVault.decode(vaultData, passphrase: passphrase)
            return true
        }
        catch {
            DDLogError("Unable to open vault file: \(error)")
            return false
        }
        
    }

}
