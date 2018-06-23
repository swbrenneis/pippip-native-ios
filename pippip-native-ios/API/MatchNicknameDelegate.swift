//
//  MatchNicknameObserver.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class MatchNicknameDelegate: EnclaveDelegate<MatchNicknameRequest, MatchNicknameResponse> {

    override init(request: MatchNicknameRequest) {
        super.init(request: request)

        requestComplete = self.matchComplete
        requestError = self.matchError

    }
    
    func matchComplete(response: MatchNicknameResponse) {
        NotificationCenter.default.post(name: Notifications.NicknameMatched, object: response)
    }

    func matchError(_ reason: String) {
        print("Match nickname error: \(reason)")
    }

}
