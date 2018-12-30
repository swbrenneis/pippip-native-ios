//
//  AuthChallengeStep.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/28/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import CocoaLumberjack

class AuthChallengeStep: NSObject, AuthStepProtocol {
    
    var authContext: AuthContextProtocol?
    var alertPresenter = AlertPresenter()
    
    func authenticationChallenge() {

        SecommAPI.instance.doPost(request: ClientAuthChallenge(), responseType: ServerAuthChallenge.self)
        .done { response -> Void in
            do {
                if let error = response.error {
                    DDLogError("Authentication challenge error: \(error)")
                    self.alertPresenter.errorAlert(title: "Authentication Error", message: "Authentication nfailed, please try again")
                    self.authContext?.authComplete(success: false)
                }
                else {
                    try response.processResponse()
                    self.authContext?.nextStep(step: AuthorizedStep())
                }
            }
            catch {
                DDLogError("Authentication challenge error: \(error.localizedDescription)")
                self.alertPresenter.errorAlert(title: "Authentication Error", message: "Authentication nfailed, please try again")
                self.authContext?.authComplete(success: false)
            }
        }
        .catch { error in
            DDLogError("Authentication challenge error: \(error.localizedDescription)")
            self.alertPresenter.errorAlert(title: "Authentication Error", message: "Authentication nfailed, please try again")
            self.authContext?.authComplete(success: false)
        }

    }
    
    func step(authContext: AuthContextProtocol) {
        
        self.authContext = authContext
        authenticationChallenge()
        
    }
    

}
