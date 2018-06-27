//
//  UpdateWhitelistDelegate.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

enum WhitelistUpdateType { case addEntry, deleteEntry }

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
        case .addEntry:
            if  response.action == "add", response.result == "added" || response.result == "exists" {
                NotificationCenter.default.post(name: Notifications.WhitelistEntryAdded, object: response)
            }
            else {
                print("Invalid response from server to add whitelist entry update")
            }
            break
        case .deleteEntry:
            if  response.action == "delete", response.result == "deleted" || response.result == "not found" {
                NotificationCenter.default.post(name: Notifications.WhitelistEntryDeleted, object: nil)
            }
            else {
                print("Invalid response from server to delete whitelist entry update")
            }
            break
        }
 
    }

    func updateError(_ reason: String) {
        print("Update whitelist error: \(reason)")
    }

}
