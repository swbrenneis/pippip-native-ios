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

    @objc static var sessionTTL: Int64 = 0

    var viewController: UIViewController
    var view: UIView
    var authView: AuthView
    var suspended = false
    var sessionState = SessionState()
    var config = Configurator()
    var authenticator = Authenticator()
    @objc var listening: Bool {
        didSet {
            if listening {
                NotificationCenter.default.addObserver(self, selector: #selector(appResumed(_:)),
                                                       name: Notifications.AppResumed, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(appSuspended(_:)),
                                                       name: Notifications.AppSuspended, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(sessionEnded(_:)),
                                                       name: Notifications.SessionEnded, object: nil)
                // Used to dismiss the HUD
                NotificationCenter.default.addObserver(authView, selector: #selector(AuthView.presentAlert(_:)),
                                                       name: Notifications.PresentAlert, object: nil)
            }
            else {
                NotificationCenter.default.removeObserver(self, name: Notifications.AppResumed, object: nil)
                NotificationCenter.default.removeObserver(self, name: Notifications.AppSuspended, object: nil)
                NotificationCenter.default.removeObserver(self, name: Notifications.SessionEnded, object: nil)
                NotificationCenter.default.removeObserver(authView, name: Notifications.PresentAlert, object: nil)
            }
        }
    }
    @objc var visible: Bool {
        didSet {
            if visible {
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
        authView.viewController = viewController
        let logoWidth = bounds.width * 0.7
        authView.logoLeading.constant = (bounds.width - logoWidth) / 2
        authView.logoTrailing.constant = (bounds.width - logoWidth) / 2
        let backgroundColor = UIColor.flatForestGreen.lighten(byPercentage: 0.15)!
        authView.contentView.backgroundColor = backgroundColor
        authView.authButton.setTitleColor(ContrastColorOf(backgroundColor, returnFlat: false), for: .normal)
        authView.authButton.backgroundColor = .clear
        authView.versionLabel.textColor = UIColor.flatSand
        authView.secommLabel.textColor = UIColor.flatSand

        visible = false
        listening = false

        super.init()

    }

    func doThumbprint() {
    
        assert(Thread.isMainThread)
        let laContext = LAContext()
        var authError: NSError? = nil
        if (laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError)) {
            laContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                     localizedReason: "Please provide your thumbprint to open Pippip", reply: { (success : Bool, error : Error? ) -> Void in
                                        if (success) {
                                            NotificationCenter.default.post(name: Notifications.ThumbprintComplete,
                                                                            object: nil)
                                        }
                                        else {
                                            print("Thumbprint authentication failed")
                                            self.authenticator.logout()
                                            self.authView.authButton.isHidden = false
                                        }
            })
        }
        
    }

    @objc func appResumed(_ notification: Notification) {
        
        if suspended && sessionState.authenticated {
            suspended = false
            let info = notification.userInfo!
            let suspendedTime = info["suspendedTime"] as? Int ?? 0
            var localAuth = true
            if !config.useLocalAuth || suspendedTime > LocalAuthenticator.sessionTTL {
                localAuth = false
                authenticator.logout()
            }
            
            DispatchQueue.main.async {
                if localAuth {
                    self.doThumbprint()
                }
            }
        }
        else {
            DispatchQueue.main.async {
                self.authView.authButton.isHidden = false
            }
        }
        
    }

    @objc func appSuspended(_ notification: Notification) {
        
        suspended = true
        DispatchQueue.main.async {
            self.authView.authButton.isHidden = true
            self.visible = true
        }
        
    }

    @objc func sessionEnded(_ notification: Notification) {

        DispatchQueue.main.async {
            self.authView.authButton.isHidden = false
            self.visible = true
        }

    }

}
