//
//  UpdateWhitelistDelegate.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import CocoaLumberjack

enum WhitelistUpdateType { case addEntry, deleteEntry }

class UpdateWhitelistDelegate: EnclaveDelegate<UpdateWhitelistRequest, UpdateWhitelistResponse> {

    var updateType: WhitelistUpdateType
    var publicId: String!
    var directoryId: String?
    
    init(request: UpdateWhitelistRequest, updateType: WhitelistUpdateType) {
        
        self.updateType = updateType
        super.init(request: request)

        requestComplete = self.updateComplete
        requestError = self.updateError
        responseError = self.updateError

    }

    func updateComplete(response: UpdateWhitelistResponse) {
        
        switch updateType {
        case .addEntry:
            if  response.action == "add", response.result == "added" || response.result == "exists" {
                var userInfo = [String: Any]()
                userInfo["publicId"] = publicId
                if directoryId != nil {
                    userInfo["directoryId"] = directoryId
                }
                NotificationCenter.default.post(name: Notifications.WhitelistEntryAdded, object: nil, userInfo: userInfo)
            }
            else {
                DDLogError("Invalid response from server to add whitelist entry update")
            }
            break
        case .deleteEntry:
            if  response.action == "delete", response.result == "deleted" || response.result == "not found" {
                var userInfo = [String: Any]()
                userInfo["publicId"] = publicId
                if directoryId != nil {
                    userInfo["directoryId"] = directoryId
                }
                NotificationCenter.default.post(name: Notifications.WhitelistEntryDeleted, object: nil, userInfo: userInfo)
            }
            else {
                DDLogError("Invalid response from server to delete whitelist entry update")
            }
            break
        }
 
    }

    func updateError(_ reason: String) {
        DDLogError("Update whitelist error: \(reason)")
    }

}
