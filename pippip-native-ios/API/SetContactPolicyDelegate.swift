//
//  SetContactPolicyDelegate.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class SetContactPolicyDelegate: EnclaveDelegate<SetContactPolicyRequest, SetContactPolicyResponse> {

    override init(request: SetContactPolicyRequest) {
        super.init(request: request)

        requestComplete  = self.setComplete
        requestError = self.setError

    }

    func setComplete(response: SetContactPolicyResponse) {
        NotificationCenter.default.post(name: Notifications.PolicyUpdated, object: response)
    }

    func setError(error: EnclaveResponseError) {
        print("Set contact policy error: \(error.errorString!)")
    }

}
