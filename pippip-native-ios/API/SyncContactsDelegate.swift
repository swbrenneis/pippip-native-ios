//
//  SyncContactsDelegate.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 9/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class SyncContactsDelegate: EnclaveDelegate<SyncContactsRequest, SyncContactsResponse> {

    override init(request: SyncContactsRequest) {
        super.init(request: request)
        
        requestComplete = self.setComplete
        requestError = self.setError
        responseError = self.setError
        
    }
    
    func setComplete(response: SyncContactsResponse) {

        var added = 0
        var deleted = 0
        for syncResponse in response.responses! {
            if syncResponse.result == "added" {
                added += 1
            }
            else if syncResponse.result == "deleted" {
                deleted += 1
            }
        }
        print("Sync complete, \(added) added, \(deleted) deleted")

    }
    
    func setError(_ reason: String) {
        print("Sync contacts error: \(reason)")
    }
    
}
