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
    var sessionState = SessionState()
    var config = Configurator()
    var signInView: SignInView?
    var alertPresenter = AlertPresenter()

    @objc init(viewController: UIViewController) {

        self.viewController = viewController
        
        super.init()

    }
    
    private func showAuthView() {

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

        if AccountSession.instance.newAccount {
            authView?.setNewAccount()
        }
        else {
            authView?.setSignIn()
        }

    }

    func viewWillAppear() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(appSuspended(_:)),
                                               name: Notifications.AppSuspended, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appResumed(_:)),
                                               name: Notifications.AppResumed, object: nil)
        

        if AccountSession.instance.starting {
            showAuthView()
        }

    }

    func viewWillDisappear() {
        
        NotificationCenter.default.removeObserver(self, name: Notifications.AppSuspended, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.AppResumed, object: nil)

    }

    func viewDidAppear() {
        
        if !AccountSession.instance.newAccount  && AccountSession.instance.starting {
            if config.useLocalAuth {
                authView?.biometricAuthenticate(local: false)
            }
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
            if self.config.useLocalAuth {
                self.authView?.biometricAuthenticate(local: true)
            }
            else {
                self.authView?.showSignInView(local: true)
            }
        }

    }
    
}
