//
//  SetContactStatusDelegate.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/4/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import Foundation
import CocoaLumberjack

class SetContactStatusDelegate : EnclaveDelegate<SetContactStatusRequest, SetContactStatusResponse> {
    
    override init(request: SetContactStatusRequest) {
        super.init(request: request)
        
        requestComplete = self.setComplete
        requestError = self.setError
        responseError = self.setError
        
    }
    
    func setComplete(response: SetContactStatusResponse) {
        
        ContactsModel.instance.setContactStatus(publicId: response.publicId!, status: response.status!)

    }
    
    func setError(_ reason: String) {
        DDLogError("Error setting contact status - \(reason)")
    }

}
