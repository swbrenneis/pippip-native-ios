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

    }

    func deleteComplete(response: DeleteContactResponse) {

        // If there are duplicates in the database, this will prevent crashes
        // However, duplicates will require two separate deletes
        if let contact = contactManager.getContact(publicId: response.publicId!),
            response.result == "deleted" {
            contactManager.deleteContact(contact: contact)
            messageManager.clearMessages(contactId: contact.contactId)
            NotificationCenter.default.post(name: Notifications.ContactDeleted, object: contact.publicId)
            NotificationCenter.default.post(name: Notifications.MessagesUpdated, object: nil)
        }
        else {
            print("Delete contact returned invalid public ID")
        }

    }

    func deleteError(error: EnclaveResponseError) {
        print("Delete contact error: \(error.errorString!)")
    }

}
