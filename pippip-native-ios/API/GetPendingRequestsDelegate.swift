//
//  GetPendingRequestsObserver.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import CocoaLumberjack

class GetPendingRequestsDelegate: EnclaveDelegate<GetPendingRequests, GetPendingRequestsResponse> {

    var contactManager = ContactManager.instance

    override init(request: GetPendingRequests) {
        super.init(request: request)

        requestComplete = self.getComplete
        requestError = self.getError
        responseError = self.getError

    }

    func getComplete(response: GetPendingRequestsResponse) {
        
        AsyncNotifier.notify(name: Notifications.GetRequestsComplete, object: nil)  // Notifies account session to proceed with status updates
        guard let requests = response.requests else { return }
        DDLogInfo("\(requests.count) pending requests returned")
        if requests.count > 0 {
            contactManager.addRequests(requests: requests)
            NotificationCenter.default.post(name: Notifications.SetContactBadge, object: nil)
        }
        else {
            contactManager.clearRequests()
        }
        NotificationCenter.default.post(name: Notifications.RequestsUpdated, object: contactManager.pendingRequests.count)

    }

    func getError(_ reason: String) {
        AsyncNotifier.notify(name: Notifications.GetRequestsComplete, object: nil)
        print("Get pending requests error: \(reason)")
    }

}
