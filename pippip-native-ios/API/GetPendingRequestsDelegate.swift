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

    var config = Configurator()
    
    override init(request: GetPendingRequests) {
        super.init(request: request)

        requestComplete = self.getComplete
        requestError = self.getError
        responseError = self.getError

    }

    func autoAcknowledge(requests: [ContactRequest]) {
        
        for contactRequest in requests {
            guard let puid = contactRequest.publicId else { continue }
            if ContactsModel.instance.whitelistIdExists(publicId: puid) {
                AutoAcknowledgement().acknowledge(publicId: puid)
            }
        }

    }
    
    func getComplete(response: GetPendingRequestsResponse) {
        
        AsyncNotifier.notify(name: Notifications.GetRequestsComplete, object: nil)  // Notifies account session to proceed with status updates
        guard let requests = response.requests else { return }
        DDLogInfo("\(requests.count) pending requests returned")
        if requests.count > 0 {
            var contactRequests = [ContactRequest]()
            for pair in requests {
                if let contactRequest = ContactRequest(request: pair) {
                    contactRequests.append(contactRequest)
                }
                else {
                    DDLogError("Invalid request returned, public ID missing")
                }
            }
            ContactsModel.instance.addRequests(requests: contactRequests)
            if config.contactPolicy == Configurator.whitelistPolicy {
                autoAcknowledge(requests: contactRequests)
            }
            NotificationCenter.default.post(name: Notifications.SetContactBadge, object: nil)
        }
        else {
            ContactsModel.instance.clearRequests()
        }
        NotificationCenter.default.post(name: Notifications.RequestsUpdated,
                                        object: ContactsModel.instance.pendingRequests.count)

    }

    func getError(_ reason: String) {
        AsyncNotifier.notify(name: Notifications.GetRequestsComplete, object: nil)
        print("Get pending requests error: \(reason)")
    }

}
