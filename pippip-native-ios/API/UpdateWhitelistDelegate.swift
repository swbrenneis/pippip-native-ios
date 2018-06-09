//
//  UpdateWhitelistDelegate.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

enum WhitelistUpdateType { case addFriend, deleteFriend }

class UpdateWhitelistDelegate: EnclaveDelegate<UpdateWhitelistRequest, UpdateWhitelistResponse> {

    var updateType: WhitelistUpdateType
    
    init(request: UpdateWhitelistRequest, updateType: WhitelistUpdateType) {
        
        self.updateType = updateType
        
        super.init(request: request)

        requestComplete = self.updateComplete
        requestError = self.updateError

    }

    func updateComplete(response: UpdateWhitelistResponse) {
        
        switch updateType {
        case .addFriend:
            if  response.action == "add", response.result == "added" || response.result == "exists" {
                NotificationCenter.default.post(name: Notifications.FriendAdded, object: response)
            }
            else {
                print("Invalid response from server to add friend update")
            }
            break
        case .deleteFriend:
            if  response.action == "delete", response.result == "deleted" || response.result == "not found" {
                NotificationCenter.default.post(name: Notifications.FriendDeleted, object: nil)
            }
            else {
                print("Invalid response from server to delete friend update")
            }
            break
        }
 
    }

    func updateError(error: EnclaveResponseError) {
        print("Update whitelist error: \(error.errorString!)")
    }

}
