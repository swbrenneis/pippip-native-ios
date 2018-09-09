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
import DeviceKit

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
        let logoWidth = bounds.width * 0.7
        authView.logoLeading.constant = (bounds.width - logoWidth) / 2
        authView.logoTrailing.constant = (bounds.width - logoWidth) / 2
        authView.contentView.backgroundColor = PippipTheme.splashColor
        authView.versionLabel.textColor = UIColor.flatSand
        authView.secommLabel.textColor = UIColor.flatSand

        super.init()

    }

    func doThumbprint() {
    
        assert(Thread.isMainThread)
        
        let device = Device()
        var reason = "Please provide your thumbprint to open Pippip"
        if device == .iPhoneX {
            reason = "Please use face ID to open Pippip"
        }

        let laContext = LAContext()
        var authError: NSError? = nil
        if (laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError)) {
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
            if self.suspended && self.sessionState.authenticated {
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
