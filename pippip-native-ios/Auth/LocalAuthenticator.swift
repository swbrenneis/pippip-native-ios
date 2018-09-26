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

class LocalAuthenticator: NSObject {

    var viewController: UIViewController
    var view: UIView
    var authView: AuthView
    var suspended = false
    var sessionState = SessionState()
    var config = Configurator()
    var signInView: SignInView?
    var alertPresenter = AlertPresenter()
    var listening: Bool = false {
        didSet {
            if listening {
                NotificationCenter.default.addObserver(self, selector: #selector(appResumed(_:)),
                                                       name: Notifications.AppResumed, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(appSuspended(_:)),
                                                       name: Notifications.AppSuspended, object: nil)                // Used to dismiss the HUD
            }
            else {
                NotificationCenter.default.removeObserver(self, name: Notifications.AppResumed, object: nil)
                NotificationCenter.default.removeObserver(self, name: Notifications.AppSuspended, object: nil)
            }
        }
    }
    var showAuthView: Bool = false {
        didSet {
            if showAuthView {
                assert(Thread.isMainThread)
                viewController.navigationController?.isNavigationBarHidden = true
                view.addSubview(authView)
            }
            else {
                assert(Thread.isMainThread)
                viewController.navigationController?.isNavigationBarHidden = false
                authView.removeFromSuperview()
            }
        }
    }

    @objc init(viewController: UIViewController, view: UIView) {

        self.viewController = viewController
        self.view = view

        let bounds = view.bounds;
        authView = AuthView(frame: bounds)

        super.init()

    }

    func doThumbprint() {
    
        assert(Thread.isMainThread)
        
        let laContext = LAContext()
        var authError: NSError?
        if (laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError)) {
            var reason: String = ""
            switch laContext.biometryType {
            case .none:
                print("Local authentication not supported")
                break
            case .touchID:
                reason = "Please provide your thumbprint to open Pippip"
                break
            case .faceID:
                reason = "Please use face ID to open Pippip"
                break
            }
            laContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                     localizedReason: reason, reply: { (success : Bool, error : Error? ) -> Void in
                                        DispatchQueue.main.async {
                                            if (success) {
                                                NotificationCenter.default.post(name: Notifications.LocalAuthComplete,
                                                                                object: nil)
                                            }
                                            else {
                                                guard let theError = error else { return }
                                                print("Local authentication failed: \(theError)")
                                                self.showPassphraseView()
                                            }
                                        }
            })
        }
        
    }

    func showPassphraseView() {
        
        let frame = self.view.bounds
        let viewRect = CGRect(x: 0.0, y: 0.0, width: frame.width * 0.8, height: frame.height * 0.45)
        signInView = SignInView(frame: viewRect)
        let viewCenter = CGPoint(x: self.view.center.x, y: self.view.center.y - 100)
        signInView?.center = viewCenter
        signInView?.alpha = 0.3
        
        signInView?.accountName = AccountSession.accountName!
        signInView?.blurController = authView
        signInView?.signInCompletion = validatePassphrase(passphrase:)
        
        self.view.addSubview(self.signInView!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.authView.blurView.alpha = 0.3
            self.signInView?.alpha = 1.0
        }, completion: { complete in
            self.signInView?.passphraseTextField.becomeFirstResponder()
        })
        
    }

    func validatePassphrase(passphrase: String) {

        var validated = false
        do {
            validated = try UserVault.validatePassphrase(passphrase)
        }
        catch {
            print("Passphrase validation error: \(error)")
        }
        if (validated) {
            NotificationCenter.default.post(name: Notifications.LocalAuthComplete,
                                            object: nil)
        }
        else {
            alertPresenter.errorAlert(title: "Invalid Passphrase", message: "The passphrase you entered is invalid")
        }

    }

    @objc func appResumed(_ notification: Notification) {
        
        DispatchQueue.main.async {
            if self.suspended && self.config.authenticated {
                self.suspended = false
                DispatchQueue.main.async {
                    if self.config.useLocalAuth {
                        self.doThumbprint()
                    }
                    else {
                        self.showPassphraseView()
                    }
                }
            }
        }
        
    }

    @objc func appSuspended(_ notification: Notification) {
        
        suspended = true
        DispatchQueue.main.async {
            self.showAuthView = true
        }
        
    }

}
