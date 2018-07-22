//
//  GetPendingRequestsObserver.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class GetPendingRequestsDelegate: EnclaveDelegate<GetPendingRequests, GetPendingRequestsResponse> {

    var contactManager = ContactManager()
    var alertPresenter = AlertPresenter()

    override init(request: GetPendingRequests) {
        super.init(request: request)

        requestComplete = self.getComplete
        requestError = self.getError

    }

    func getComplete(response: GetPendingRequestsResponse) {
        
        print("\(response.requests!.count) pending requests returned")
        if response.requests!.count > 0 {
            contactManager.addRequests(response.requests!)
            alertPresenter.infoAlert(title: "New Contact Requests",
                                     message: "You have \(response.requests!.count) new contact requests")
        }
        else {
            contactManager.clearRequests()
        }
        NotificationCenter.default.post(name: Notifications.RequestsUpdated, object: response.requests!.count)

    }

    func getError(_ reason: String) {
        print("Get pending requests error: \(reason)")
    }

}
