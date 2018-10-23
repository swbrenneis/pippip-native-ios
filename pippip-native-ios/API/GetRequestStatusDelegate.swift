//
//  GetRequestStatusObserver.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class GetRequestStatusDelegate: EnclaveDelegate<GetRequestStatusRequest, GetRequestStatusResponse> {

    var contactManager = ContactManager.instance
//    var publicId: String?
//    var retry: Bool
    var alertPresenter = AlertPresenter()
    var config = Configurator()

    override init(request: GetRequestStatusRequest) {

        super.init(request: request)

        requestComplete = self.getComplete
        requestError = self.getError
        responseError = self.getError

    }

    func getComplete(response: GetRequestStatusResponse) {
        
        AsyncNotifier.notify(name: Notifications.GetStatusComplete, object: nil)
        if response.contacts!.count > 0 {
            do {
                let updates = try contactManager.updateContacts(response.contacts!)
                print("\(updates.count) contacts updated")
                config.statusUpdates = updates.count
                NotificationCenter.default.post(name: Notifications.RequestStatusUpdated, object: updates)
                NotificationCenter.default.post(name: Notifications.SetContactBadge, object: nil)
                print("Status updated on \(updates.count) requests")
            }
            catch {
                print("Error updating contacts: \(error)")
            }
        }
        else {
            print("No request status updates")
        }

    }

    func getError(_ reason: String) {
        AsyncNotifier.notify(name: Notifications.GetStatusComplete, object: nil)
        print("Get request status error: \(reason)")
    }

}
