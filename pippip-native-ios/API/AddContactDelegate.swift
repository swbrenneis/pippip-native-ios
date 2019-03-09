//
//  RequestContactObserver.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import CocoaLumberjack

class AddContactDelegate: EnclaveDelegate<AddContactRequest, AddContactResponse> {

    var contactManager = ContactManager()

    override init(request: AddContactRequest) {
        
        super.init(request: request)

        requestComplete = self.contactRequestComplete
        requestError = self.contactRequestError
        responseError = self.contactRequestError

    }

    func contactRequestComplete(response: AddContactResponse) {
        
        
        let contact = Contact()
        contact.publicId = response.requestedId!
        contact.directoryId = response.directoryId
        contact.status = response.result!
        ContactsModel.instance.addPendingContact(contact)
        AsyncNotifier.notify(name: Notifications.ContactRequested, object: contact)
        
    }
    
    func contactRequestError(_ reason: String) {
        DDLogError("Contact request error: \(reason)")
    }

}
