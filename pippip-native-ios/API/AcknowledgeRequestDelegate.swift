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

    init(request: RequestT, contactRequest: ContactRequest) {
        
        self.contactRequest = contactRequest
    
        super.init(request: request)

        requestComplete = self.ackComplete
        requestError = self.ackError

    }

    func ackComplete(response: AcknowledgeRequestResponse) {

        if let acknowledged = Contact(serverContact: response.acknowledged!),
            acknowledged.publicId == contactRequest.publicId {
            acknowledged.nickname = contactRequest.nickname
            contactManager.addContact(acknowledged)
            contactManager.deleteContactRequest(contactRequest)
            DispatchQueue.global().async {
                NotificationCenter.default.post(name: Notifications.RequestAcknowledged, object: acknowledged)
            }
        }
        else {
            print("Invalid server response, invalid contact JSON")
        }

    }
    
    func ackError(error: EnclaveResponseError) {
        print("Acknowledge request error: \(error.errorString!)")
    }

}
