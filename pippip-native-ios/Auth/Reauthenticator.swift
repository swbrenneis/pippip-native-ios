//
//  Reauthenticator.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/28/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

class Reauthenticator<ResponseT: EnclaveResponseProtocol>: NSObject, AuthContextProtocol {
    
    var currentStep: AuthStepProtocol?
    var requester: EnclaveRequester<ResponseT>?
    
    func authComplete(success: Bool) {

        requester?.doRequest()
        
    }
    
    func nextStep(step: AuthStepProtocol) {
        
        currentStep = step
        currentStep?.step(authContext: self)
    
    }
    
    func reauthenticate(requester: EnclaveRequester<ResponseT>) {

        self.requester = requester
        currentStep = AuthenticationRequestStep()
        currentStep?.step(authContext: self)
        
    }
    
}
