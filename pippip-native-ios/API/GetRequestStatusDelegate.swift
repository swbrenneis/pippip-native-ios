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
    var publicId: String?
    var retry: Bool
    var alertPresenter = AlertPresenter()

    init(request: GetRequestStatusRequest, publicId: String?, retry: Bool) {

        self.publicId = publicId
        self.retry = retry

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
                var message = "You have \(updated.count) contact status "
                if updated.count == 1 {
                    message += "update"
                }
                else {
                    message += "updates"
                }
                alertPresenter.infoAlert(title: "Contact Status Updates", message: message)
            }
            catch {
                print("Error updating contacts: \(error)")
            }
        }
        else if retry {
            contactManager.requestContact(publicId: publicId!, directoryId: nil, retry: true)
        }

    }

    func getError(_ reason: String) {
        print("Get request status error: \(reason)")
    }

}
