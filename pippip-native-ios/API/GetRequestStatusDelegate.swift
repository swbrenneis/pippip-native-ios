//
//  GetRequestStatusObserver.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class GetRequestStatusDelegate: EnclaveDelegate<GetRequestStatusRequest, GetRequestStatusResponse> {

    var contactManager = ContactManager()
    var publicId: String
    var retry: Bool

    init(request: GetRequestStatusRequest, publicId: String, retry: Bool) {

        self.publicId = publicId
        self.retry = retry

        super.init(request: request)

        requestComplete = getComplete
        requestError = getError

    }

    func getComplete(response: GetRequestStatusResponse) {
        
        if response.contacts!.count > 0 {
            let updated = contactManager.updateContacts(response.contacts!)
            NotificationCenter.default.post(name: Notifications.RequestStatusUpdated, object: updated)
            print("\(updated.count) contacts updated")
        }
        else if retry {
            contactManager.requestContact(publicId: publicId, nickname: nil, retry: true)
        }

    }

    func getError(error: EnclaveResponseError) {
        print("Get request status error: \(error.errorString!)")
    }

}
