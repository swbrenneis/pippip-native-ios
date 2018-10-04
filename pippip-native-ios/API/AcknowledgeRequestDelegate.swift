//
//  AcknowledgeRequestObserver.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class AcknowledgeRequestDelegate: EnclaveDelegate<AcknowledgeRequest, AcknowledgeRequestResponse> {

    var contactRequest: ContactRequest
    var contactManager = ContactManager()
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
            let acknowledged = Contact(serverContact: response.acknowledged!)
            if acknowledged.publicId == contactRequest.publicId {
                acknowledged.directoryId = contactRequest.directoryId
                contactManager.addContact(acknowledged)
                contactManager.deleteContactRequest(contactRequest)
                DispatchQueue.global().async {
                    NotificationCenter.default.post(name: Notifications.RequestAcknowledged, object: acknowledged)
                    NotificationCenter.default.post(name: Notifications.SetContactBadge, object: nil)
                }
            }
            else {
                print("Invalid server response, invalid contact JSON")
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
