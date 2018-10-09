//
//  LocalAuthenticator.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/17/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework
import LocalAuthentication

class LocalAuthenticator: NSObject, AuthenticationDelegateProtocol {

    var viewController: UIViewController?
//    var view: UIView?
    var authView: AuthView?
    var sessionState = SessionState()
    var config = Configurator()
    var signInView: SignInView?
    var alertPresenter = AlertPresenter()
    var authPrompt: String = ""
    var accountName: String
    var authenticator: Authenticator
    var newAccountCreator: NewAccountCreator

    @objc init(viewController: UIViewController, initial: Bool) {

        self.viewController = viewController
        accountName = AccountSession.instance.accountName
        authenticator = Authenticator()
        newAccountCreator = NewAccountCreator()

        let laContext = LAContext()
        var authError: NSError?
        if (laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError)) {
            switch laContext.biometryType {
            case .none:
                print("Local authentication not supported")
                break
            case .touchID:
                authPrompt = "Please provide your thumbprint to open Pippip"
                break
            case .faceID:
                authPrompt = "Please use face ID to open Pippip"
                break
            }
        }
        
        super.init()

        authenticator.delegate = self
        newAccountCreator.delegate = self

    }

    override init() {   // Used when setting up keychain biometrics
        
        accountName = AccountSession.instance.accountName
        authenticator = Authenticator()
        newAccountCreator = NewAccountCreator()

        let laContext = LAContext()
        var authError: NSError?
        if (laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError)) {
            switch laContext.biometryType {
            case .none:
                print("Local authentication not supported")
                break
            case .touchID:
                authPrompt = "Please provide your thumbprint to open Pippip"
                break
            case .faceID:
                authPrompt = "Please use face ID to open Pippip"
                break
            }
        }

        super.init()
        
    }

    func getKeychainPassphrase(uuid: String) {

        let keychain = Keychain(service: "io.pippip.token")
        var passphrase: String?
        DispatchQueue.global().async {
            do {
                passphrase = try keychain.authenticationPrompt(self.authPrompt)
                                         .get(key: uuid)
            }
            catch {
                print("Error retrieving keychain passphrase: \(error)")
            }
            if passphrase == nil  && !keychain.canceled {
                self.config.useLocalAuth = false
            }
            NotificationCenter.default.post(name: Notifications.PassphraseReady, object: passphrase)
        }

    }

    func doAuthenticate(passphrase: String) {

        if AccountSession.instance.authenticated {
            var success = false
            do {
                success = try UserVault.validatePassphrase(accountName: AccountSession.instance.accountName, passphrase: passphrase)
            }
            catch {
                print("Failed to validate saved passphrase: \(error)")
            }
            if success {
                DispatchQueue.main.async {
                    self.viewController?.navigationController?.isNavigationBarHidden = false
                    self.authView?.dismiss(completion: {(completed) in })
                }
            }
            else {
                alertPresenter.errorAlert(title: "Authentication Error", message: "Biometric authentication failed")
                authenticator.logout()
                DispatchQueue.global().async {
                    self.authView?.enableAuthentication()
               }
            }
        }
        else {
            authenticator.authenticate(accountName: accountName, passphrase: passphrase)
        }

    }
    
    func doNewAccount(accountName: String, passphrase: String, biometricsEnabled: Bool) {
        
        newAccountCreator.createAccount(accountName: accountName, passphrase: passphrase, biometricsEnabled: biometricsEnabled)
        
    }
    
    func setKeychainPassphrase(uuid: String, passphrase: String) {
        
        let keychain = Keychain(service: "io.pippip.token")
        DispatchQueue.global().async {
            do {
                try keychain.accessibility(protection: .passcodeSetThisDeviceOnly, createFlag: .userPresence)
                            .set(passphrase: passphrase, key: uuid)
            }
            catch {
                print("Error adding passphrase to keychain: \(error)")
                self.alertPresenter.errorAlert(title: "Authentication Error", message: "Unable to store passphrase")
            }
        }
        
    }
    
    private func showAuthView(suspending: Bool) {

        assert(Thread.isMainThread)
        viewController!.navigationController?.isNavigationBarHidden = true
        if authView == nil {
            let bounds = viewController!.view.bounds;
            authView = AuthView(frame: bounds)
            authView!.localAuthenticator = self
            if let blurController = viewController as? ControllerBlurProtocol {
                authView?.blurController = blurController
            }
            viewController!.view.addSubview(authView!)
        }
        authView?.blurController?.blurView.alpha = 0.6
        authView?.alpha = 1.0
        authView?.center = viewController!.view.center
        if !suspending {
            authView?.enableAuthentication()
        }
        
    }
    /*
    func showSignInView() {

        guard let view = viewController?.view else { return }
        let frame = view.bounds
        let viewRect = CGRect(x: 0.0, y: 0.0,
                              width: frame.width * PippipGeometry.signInViewWidthRatio,
                              height: frame.height * PippipGeometry.signInViewHeightRatio)
        signInView = SignInView(frame: viewRect)
        let viewCenter = CGPoint(x: view.center.x, y: view.center.y - PippipGeometry.signInViewOffset)
        signInView?.center = viewCenter
        signInView?.alpha = 0.3
        
        signInView?.accountName = accountName
        signInView?.blurController = authView
        signInView?.signInCompletion = validatePassphrase(passphrase:)
        
        view.addSubview(signInView!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.authView!.blurView.alpha = 0.6
            self.signInView?.alpha = 1.0
        }, completion: { complete in
            self.signInView?.passphraseTextField.becomeFirstResponder()
        })
        
    }

    func validatePassphrase(passphrase: String) {

        var validated = false
        do {
            validated = try UserVault.validatePassphrase(accountName: accountName, passphrase: passphrase)
        }
        catch {
            print("Passphrase validation error: \(error)")
        }
        if (validated) {
            NotificationCenter.default.post(name: Notifications.AuthComplete, object: nil)
        }
        else {
            alertPresenter.errorAlert(title: "Invalid Passphrase", message: "The passphrase you entered is invalid")
        }

    }
*/
    func viewWillAppear() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(appSuspended(_:)),
                                               name: Notifications.AppSuspended, object: nil)                // Used to dismiss the HUD
        if !AccountSession.instance.authenticated {
            showAuthView(suspending: false)
        }

    }
    
    func viewDidDisappear() {
        
        NotificationCenter.default.removeObserver(self, name: Notifications.AppResumed, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.AppSuspended, object: nil)

    }
    
    // Notifications
    
    @objc func appResumed(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.AppResumed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appSuspended(_:)),
                                               name: Notifications.AppSuspended, object: nil)                // Used to dismiss the HUD
        DispatchQueue.main.async {
            self.authView?.enableAuthentication()
        }

    }

    @objc func appSuspended(_ notification: Notification) {
        
        NotificationCenter.default.removeObserver(self, name: Notifications.AppSuspended, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appResumed(_:)),
                                               name: Notifications.AppResumed, object: nil)
        DispatchQueue.main.async {
            self.showAuthView(suspending: true)
        }
        
    }

    // Authentication delegate

    func authenticated() {

        DispatchQueue.main.async {
            self.authView?.dismiss(completion: { (completed) in
                self.viewController?.navigationController?.isNavigationBarHidden = false
            })
        }
        AsyncNotifier.notify(name: Notifications.AuthComplete, object: nil)

    }
    
    func authenticationFailed(reason: String) {
        
    }
    
    func loggedOut() {
        
        authView?.alpha = 1.0

    }
    
}
