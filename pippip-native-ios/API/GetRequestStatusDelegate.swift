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
//    var publicId: String?
//    var retry: Bool
    var alertPresenter = AlertPresenter()
    var accountSession = ApplicationInitializer.accountSession
    var config = Configurator()

    override init(request: GetRequestStatusRequest) {

//        self.publicId = publicId
//        self.retry = retry

        super.init(request: request)

        requestComplete = self.getComplete
        requestError = self.getError
        responseError = self.getError

    }

    func getComplete(response: GetRequestStatusResponse) {
        
        if response.contacts!.count > 0 {
            do {
                let updated = try contactManager.updateContacts(response.contacts!)
                NotificationCenter.default.post(name: Notifications.RequestStatusUpdated, object: updated)
                print("\(updated.count) contacts updated")
                config.statusUpdates = config.statusUpdates + updated.count
                NotificationCenter.default.post(name: Notifications.SetContactBadge, object: nil)
                print("Status updated on \(updated.count) requests")
            }
            catch {
                print("Error updating contacts: \(error)")
            }
        }
        //else if retry {
        //    contactManager.requestContact(publicId: publicId!, directoryId: nil, retry: true)
        //}
        else {
            print("No request status updates")
        }

    }

    func getError(_ reason: String) {
        print("Get request status error: \(reason)")
    }

}
