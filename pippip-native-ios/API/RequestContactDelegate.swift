//
//  RequestContactObserver.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class RequestContactDelegate: EnclaveDelegate<RequestContactRequest, RequestContactResponse> {

    var retry: Bool
    var directoryId: String?
    var contactManager = ContactManager()

    init(request: RequestContactRequest, retry: Bool, directoryId: String?) {
        
        self.retry = retry
        self.directoryId = directoryId
        
        super.init(request: request)

        requestComplete = self.contactRequestComplete
        requestError = self.contactRequestError
        responseError = self.contactRequestError

    }

    func contactRequestComplete(response: RequestContactResponse) {
        
        if !retry {
            let contact = Contact()
            if response.version! >= 1.1 {
                contact.publicId = response.requestedId!
            }
            else {
                contact.publicId = response.requestedContactId!
            }
            contact.directoryId = directoryId
            contact.status = response.result!
            contactManager.addContact(contact)
            NotificationCenter.default.post(name: Notifications.ContactRequested, object: contact)
        }

    }
    
    func contactRequestError(_ reason: String) {
        print("Contact request error: \(reason)")
    }

}
