//
//  DeleteContactObserver.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import CocoaLumberjack

class DeleteContactDelegate: EnclaveDelegate<DeleteContactRequest, DeleteContactResponse> {

    var alertPresenter = AlertPresenter()
    
    override init(request: DeleteContactRequest) {
        super.init(request: request)

        requestComplete = self.deleteComplete
        requestError = self.deleteError
        responseError = self.deleteError

    }

    func deleteComplete(response: DeleteContactResponse) {

        guard let result = response.result else {
            DDLogError("Invalid server response, missing result")
            alertPresenter.errorAlert(title: "Delete Contact Error", message: Strings.errorServerResponse)
            return
        }
        DDLogInfo("Delete contact result: \(result)")
        if let contact = ContactsModel.instance.getContact(publicId: response.publicId!) {
            do {
                try ContactsModel.instance.deleteContact(contact: contact)
                let messageManager = MessageManager()
                messageManager.clearMessages(contactId: contact.contactId)
                NotificationCenter.default.post(name: Notifications.ContactDeleted, object: contact.publicId)
            }
            catch {
                DDLogError("Error while deleting contact: \(error.localizedDescription)")
                alertPresenter.errorAlert(title: "Delete Contact Error", message: Strings.errorInternal)
            }
        }
        else {
            DDLogError("Contact doesn't exist in local database")
            alertPresenter.errorAlert(title: "Delete Contact Error", message: Strings.errorInternal)
        }

    }

    func deleteError(_ reason: String) {
        DDLogError("Delete contact error: \(reason)")
    }

}
