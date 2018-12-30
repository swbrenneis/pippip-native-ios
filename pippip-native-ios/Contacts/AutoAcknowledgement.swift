//
//  AutoAcknowledgement.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation
import CocoaLumberjack

class AutoAcknowledgement: NSObject, ObserverProtocol {
    
    var contact: Contact?
    var contactRequest: ContactRequest?
    var alertPresenter = AlertPresenter()

    override init() {
        super.init()
        
        ContactsModel.instance.addObserver(action: .acknowledged, observer: self)

    }

    func acknowledge(publicId: String) {
    
        let contactManager = ContactManager()
        do {
            try contactManager.acknowledgeRequest(publicId: publicId, response: "accept",
                                                  onResponse: { response -> Void in self.onResponse(response: response) },
                                                  onError: { error in self.onError(error: error) })
        }
        catch {
            DDLogError("Acknowledge request error: \(error.localizedDescription)")
            alertPresenter.errorAlert(title: "Acknowledge Contact Error", message: Strings.errorServerResponse)
        }
        
    }
    
    func onError(error: String) {
        DDLogError("Acknowledge request response error: \(error)")
        alertPresenter.errorAlert(title: "Acknowledge Contact Error", message: Strings.errorServerResponse)
    }
    
    func onResponse(response: AcknowledgeRequestResponse) {
        
        if let error = response.error {
            DDLogError("Acknowledge request response error: \(error)")
            alertPresenter.errorAlert(title: "Acknowledge Contact Error", message: Strings.errorServerResponse)
        }
        else {
            guard let acknowledged = response.acknowledged else { return }
            do {
                contact = Contact(serverContact: acknowledged)
                ContactsModel.instance.addObserver(action: .added, observer: self)
                try ContactsModel.instance.addContact(contact: contact!)
            }
            catch {
                DDLogError("Error adding acknowledged contact: \(error.localizedDescription)")
                alertPresenter.errorAlert(title: "Acknowledge Contact Error", message: Strings.errorInternal)
            }
        }
        
    }
    
    func update(observable: ObservableProtocol, object: Any?) {

        guard let contactsModel = object as? ContactsModel else { return }
        contactsModel.removeObserver(action: .added, observer: self)
        do {
            try contactsModel.contactAcknowledged(contact: contact!)
            contactsModel.deleteContactRequest(contactRequest!)
        }
        catch {
            DDLogError("Update error: \(error.localizedDescription)")
            alertPresenter.errorAlert(title: "Acknowledge Contact Error", message: Strings.errorInternal)
        }
        
    }

}
