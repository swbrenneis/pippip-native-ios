//
//  SetDirectoryIdDelegate.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class SetDirectoryIdDelegate: EnclaveDelegate<SetDirectoryIdRequest, SetDirectoryIdResponse> {

    override init(request: SetDirectoryIdRequest) {
        super.init(request: request)

        requestComplete = self.setComplete
        requestError = self.setError
        responseError = self.setError

    }

    func setComplete(response: SetDirectoryIdResponse) {
        NotificationCenter.default.post(name: Notifications.DirectoryIdUpdated, object: response)
    }

    func setError(_ reason: String) {
        print("Set directory ID error: \(reason)")
    }

}
