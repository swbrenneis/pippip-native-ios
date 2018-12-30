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

class Authenticator: NSObject {

    var viewController: UIViewController?
    var authView: AuthView?
    var sessionState = SessionState.instance
    var config = Configurator()
    var signInView: SignInView?
    var alertPresenter = AlertPresenter()

    @objc init(viewController: UIViewController) {

        self.viewController = viewController
        
        super.init()

    }
    
    func showAuthView() {

        assert(Thread.isMainThread)
        viewController?.navigationController?.isNavigationBarHidden = true
        if authView == nil {
            let bounds = viewController!.view.bounds;
            authView = AuthView(frame: bounds)
            authView?.authenticator = self
            authView?.navigationController = viewController?.navigationController
            if let blurController = viewController as? ControllerBlurProtocol {
                authView?.blurController = blurController
            }
            viewController!.view.addSubview(authView!)
        }
        authView?.blurController?.blurView.alpha = 0.6
        authView?.alpha = 1.0
        authView?.center = viewController!.view.center
        authView?.hideToastActivity()

        if AccountSession.instance.newAccount {
            authView?.setNewAccount()
        }
        else if config.useLocalAuth {
            authView?.setBiometrics(showButton: false)
        }
        else {
            authView?.setSignIn()
        }

    }

    func signOut() {
        
        showAuthView()
        authView?.setSignIn()
        
    }
    
    func viewWillAppear() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(appSuspended(_:)),
                                               name: Notifications.AppSuspended, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appResumed(_:)),
                                               name: Notifications.AppResumed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(serverUnavailable(_:)),
                                               name: Notifications.ServerUnavailable, object: nil)


        if AccountSession.instance.starting {
            showAuthView()
        }

    }

    func viewWillDisappear() {
        
        NotificationCenter.default.removeObserver(self, name: Notifications.AppSuspended, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.AppResumed, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.ServerUnavailable, object: nil)

    }

    func viewDidAppear() {
        
        if AccountSession.instance.starting {
            authView?.authenticate()
        }
        
    }

    // Notifications

    @objc func appSuspended(_ notification: Notification) {
        
        DispatchQueue.main.async {
            self.showAuthView()
        }

    }
    
    @objc func appResumed(_ notification: Notification) {
        
        DispatchQueue.main.async {
            self.authView?.authenticate()
        }

    }

    @objc func serverUnavailable(_ notification: Notification) {
        
        DispatchQueue.main.async {
            self.authView?.cancelAuthentication()
            if self.config.useLocalAuth {
                self.authView?.setBiometrics(showButton: true)
            }
            else {
                self.authView?.setSignIn()
            }
        }
        
    }
    
}
