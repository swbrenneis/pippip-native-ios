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
    var nickname: String?
    var contactManager = ContactManager()

    init(request: RequestContactRequest, retry: Bool, nickname: String?) {
        
        self.retry = retry
        self.nickname = nickname
        
        super.init(request: request)

        requestComplete = self.contactRequestComplete
        requestError = self.contactRequestError

    }

    func contactRequestComplete(response: RequestContactResponse) {
        
        if !retry {
            let contact = Contact()
            contact.publicId = response.requestedContactId!
            contact.nickname = nickname
            contact.status = response.result!
            contactManager.addContact(contact)
            NotificationCenter.default.post(name: Notifications.ContactRequested, object: contact)
        }

    }
    
    func contactRequestError(error: EnclaveResponseError) {
        print("Contact request error: \(error.errorString!)")
    }

}
