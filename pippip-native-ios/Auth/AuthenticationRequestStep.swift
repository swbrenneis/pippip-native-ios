//
//  AuthenticationRequesStep.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/28/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import CocoaLumberjack

class AuthenticationRequestStep: NSObject, AuthStepProtocol {
    
    var authContext: AuthContextProtocol?
    var alertPresenter = AlertPresenter()
    
    func authenticationRequest() {
        
        SecommAPI.instance.doPost(request: AuthenticationRequest(), responseType: AuthenticationResponse.self)
        .done { response -> Void in
            do {
                if let error = response.error {
                    DDLogError("Authentication request error: \(error)")
                    self.alertPresenter.errorAlert(title: "Authentication Error", message: "Authentication failed, please try again")
                    self.authContext?.authComplete(success: false)
                }
                else {
                    try response.processResponse()
                    self.authContext?.nextStep(step: AuthChallengeStep())
                }
            }
            catch {
                DDLogError("Authentication response error: \(error.localizedDescription)")
                self.alertPresenter.errorAlert(title: "Authentication Error", message: "Authentication failed, please try again")
                self.authContext?.authComplete(success: false)
            }
        }
        .catch { error in
            DDLogError("Authentication response error: \(error.localizedDescription)")
            self.alertPresenter.errorAlert(title: "Authentication Error", message: "Authentication failed, please try again")
            self.authContext?.authComplete(success: false)
        }
        
    }
    
    func step(authContext: AuthContextProtocol) {
        
        self.authContext = authContext
        authenticationRequest()
        
    }
    

}
