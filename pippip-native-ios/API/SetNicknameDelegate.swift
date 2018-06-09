//
//  SetNicknameDelegate.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class SetNicknameDelegate: EnclaveDelegate<SetNicknameRequest, SetNicknameResponse> {

    override init(request: SetNicknameRequest) {
        super.init(request: request)

        requestComplete = self.setComplete
        requestError = self.setError

    }

    func setComplete(response: SetNicknameResponse) {
        NotificationCenter.default.post(name: Notifications.NicknameUpdated, object: response)
    }

    func setError(error: EnclaveResponseError) {
        print("Set nickname error: \(error.errorString!)")
    }

}
