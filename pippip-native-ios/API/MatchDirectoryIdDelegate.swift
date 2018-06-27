//
//  MatchDirectoryIdObserver.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class MatchDirectoryIdDelegate: EnclaveDelegate<MatchDirectoryIdRequest, MatchDirectoryIdResponse> {

    override init(request: MatchDirectoryIdRequest) {
        super.init(request: request)

        requestComplete = self.matchComplete
        requestError = self.matchError

    }
    
    func matchComplete(response: MatchDirectoryIdResponse) {
        NotificationCenter.default.post(name: Notifications.DirectoryIdMatched, object: response)
    }

    func matchError(_ reason: String) {
        print("Match directory ID error: \(reason)")
    }

}
