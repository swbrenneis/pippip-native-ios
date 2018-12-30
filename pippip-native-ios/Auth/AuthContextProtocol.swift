//
//  AuthContextProtocol.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/28/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

protocol AuthContextProtocol {
    
    func authComplete(success: Bool)
    
    func nextStep(step: AuthStepProtocol)
    
}
