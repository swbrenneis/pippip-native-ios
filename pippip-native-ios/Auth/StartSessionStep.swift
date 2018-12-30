//
//  StartSessionStep.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/28/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation
import CocoaLumberjack

class StartSessionStep: NSObject, AuthStepProtocol {
    
    var authContext: AuthContextProtocol?
    var alertPresenter = AlertPresenter()
    
    func startSession() {
        
        SecommAPI.instance.startSession()
        .done { response -> Void in
            if let error = response.error {
                DDLogError("Session response error: \(error)")
                self.alertPresenter.errorAlert(title: "Authentication Error",
                                               message: "Unable to establish a session with the server")
            }
            else {
                let sessionState = SessionState.instance
                sessionState.sessionId = response.sessionId!
                let pem = CKPEMCodec()
                sessionState.serverPublicKey = pem.decodePublicKey(response.serverPublicKey!)
                SecommAPI.instance.sessionActive = true
                self.authContext?.nextStep(step: AuthenticationRequestStep())
            }
        }
        .catch { error in
            DDLogError("Session response error: \(error.localizedDescription)")
            self.alertPresenter.errorAlert(title: "Authentication Error",
                                           message: "Unable to establish a session with the server")
        }
        
    }
    
    func step(authContext: AuthContextProtocol) {
        
        self.authContext = authContext
        startSession()
        
    }
    

}
