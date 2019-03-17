//
//  Reauthenticator.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/10/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import Foundation

class Reauthenticator<RequestT: EnclaveRequestProtocol> : ServerAuthenticator {

    var request: RequestT
    
    init(request: RequestT) {
        self.request = request
        super.init(authView: nil)
    }

    func authenticate() {
        
    }
}
