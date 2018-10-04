//
//  DeleteContactObserver.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class DeleteContactDelegate: EnclaveDelegate<DeleteContactRequest, DeleteContactResponse> {

    var contactManager = ContactManager()
    var messageManager = MessageManager()

    override init(request: DeleteContactRequest) {
        super.init(request: request)

        requestComplete = self.deleteComplete
        requestError = self.deleteError
        responseError = self.deleteError

    }

    func deleteComplete(response: DeleteContactResponse) {

        // If there are duplicates in the database, this will prevent crashes
        // However, duplicates will require two separate deletes
        let result = response.result ?? "invalid response"
        print("Delete contact result: \(result)")
        if let contact = contactManager.getContact(publicId: response.publicId!) {
            contactManager.deleteContact(contact: contact)
            messageManager.clearMessages(contactId: contact.contactId)
            NotificationCenter.default.post(name: Notifications.ContactDeleted, object: contact.publicId)
        }
        else {
            print("Contact doesn't exist in local database")
        }

    }

    func deleteError(_ reason: String) {
        print("Delete contact error: \(reason)")
    }

}
