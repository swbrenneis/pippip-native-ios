//
//  AuthorizedStep.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/28/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import CocoaLumberjack

class AuthorizedStep: NSObject, AuthStepProtocol {

    var authContext: AuthContextProtocol?
    var alertPresenter = AlertPresenter()
    
    func authorized() {
        
        SecommAPI.instance.doPost(request: ServerAuthorized(), responseType: ClientAuthorized.self)
        .done { response -> Void in
            do {
                if let error = response.error {
                    DDLogError("Client authorization error : \(error)")
                    self.alertPresenter.errorAlert(title: "Authentication Error", message: "Authentication failed, please try again")
                    self.authContext?.authComplete(success: false)
                }
                else {
                    try response.processResponse()
                    SessionState.instance.authToken = response.authToken!
                    AccountSession.instance.authenticated()
                    self.authContext?.authComplete(success: true)
                }
            }
            catch {
                DDLogError("Client authorized error: \(error.localizedDescription)")
                self.alertPresenter.errorAlert(title: "Authentication Error", message: "Authentication failed, please try again")
                self.authContext?.authComplete(success: false)
            }
        }
        .catch { error in
            DDLogError("Client authorized error: \(error.localizedDescription)")
            self.alertPresenter.errorAlert(title: "Authentication Error", message: "Authentication failed, please try again")
            self.authContext?.authComplete(success: false)
        }
    
    }
    
    func step(authContext: AuthContextProtocol) {
        
        self.authContext = authContext
        authorized()
        
    }
    

}
