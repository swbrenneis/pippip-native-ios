//
//  AcknowledgeRequestObserver.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import CocoaLumberjack

class AcknowledgeRequestDelegate: EnclaveDelegate<AcknowledgeRequest, AcknowledgeRequestResponse> {

    var contactRequest: ContactRequest
    var contactManager = ContactManager.instance
    var alertPresenter = AlertPresenter()

    init(request: RequestT, contactRequest: ContactRequest) {
        
        self.contactRequest = contactRequest
    
        super.init(request: request)

        requestComplete = self.ackComplete
        requestError = self.ackRequestError
        responseError = self.ackResponseError

    }

    func ackComplete(response: AcknowledgeRequestResponse) {

        if response.error != nil {
            alertPresenter.errorAlert(title: "Contact Request Error", message: response.error!)
        }
        else {
            guard let acknowledged = response.acknowledged else { return }
            do {
                acknowledged.directoryId = contactRequest.directoryId
                let contact = try contactManager.addContact(serverContact: acknowledged)
                contactManager.deleteContactRequest(contactRequest)
                contactManager.contactAcknowledged(contact: contact)
                AsyncNotifier.notify(name: Notifications.RequestAcknowledged, object: contact)
                AsyncNotifier.notify(name: Notifications.SetContactBadge)
            }
            catch {
                DDLogError("Error adding acknowledged contact: \(error.localizedDescription)")
            }
        }

    }

    func ackRequestError(_ reason: String) {
        print("Acknowledge request error: \(reason)")
    }
    
    func ackResponseError(_ reason: String) {
        print("Acknowledge response error: \(reason)")
        alertPresenter.errorAlert(title: "Contact Request Error", message: reason)
    }
    
}
