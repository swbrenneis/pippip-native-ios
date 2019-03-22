//
//  ContactManager.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/10/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation
import CocoaLumberjack

class ContactManager {

    var sessionState = SessionState()
    var config = Configurator()
    var alertPresenter = AlertPresenter()
    
    func acknowledgeRequest(contactRequest: ContactRequest, response: String) {

        let request = AcknowledgeRequest(requestingId: contactRequest.publicId, response: response)
        let ackTask = EnclaveTask<AcknowledgeRequest, AcknowledgeRequestResponse>()
        ackTask.sendRequest(request: request)
            .then({ response in
                if let errorString = response.error {
                    DDLogError("Acknowledge request error from server - \(errorString)")
                    self.alertPresenter.errorAlert(title: "Contact Request Error", message: Strings.errorRequestFailed)
                } else {
                    if let acknowledged = response.acknowledged,
                        let contact = Contact(serverContact: acknowledged) {
                        ContactsModel.instance.addContact(contact)
                        ContactsModel.instance.contactAcknowledged(contact: contact, request: contactRequest)
                        self.alertPresenter.successAlert(message: "This contact request has been \(contact.status)")
                        AsyncNotifier.notify(name: Notifications.RequestAcknowledged, object: contact)
                        AsyncNotifier.notify(name: Notifications.SetContactBadge)
                    } else {
                        self.alertPresenter.errorAlert(title: "Server Error", message: Strings.errorInvalidResponse)
                    }
                }
            })
            .catch ({ error in
                DDLogError("Acknowledge request error - \(error.localizedDescription)")
                self.alertPresenter.errorAlert(title: "Contact Request Error", message: Strings.errorRequestFailed)
            })

    }

    // Assumes existing contact validation has been done
    func addContactRequest(publicId: String?, directoryId: String?, pendingMessage: String?) {
 
        var initialMessage = false
        if let _ = pendingMessage {
            initialMessage = true
        }
        let request = AddContactRequest(publicId: publicId, directoryId: directoryId, initialMessage: initialMessage)
        let reqTask = EnclaveTask<AddContactRequest, AddContactResponse>()
        reqTask.sendRequest(request: request)
        .then( { response in
            if response.result == AddContactResponse.ID_NOT_FOUND {
                self.alertPresenter.errorAlert(title: "Directory ID Error", message: Strings.errorIdNotFound)
            } else if response.result == AddContactResponse.PENDING || response.result == AddContactResponse.CONTACT_UPDATED {
                if let contact = Contact(serverContact: response.contact) {
                    contact.pendingMessage = pendingMessage
                    ContactsModel.instance.addContact(contact)
                    AsyncNotifier.notify(name: Notifications.ContactRequested, object: contact)
                } else {
                    self.alertPresenter.errorAlert(title: "Server Error", message: Strings.errorInvalidResponse)
                }
            } else {
                self.alertPresenter.errorAlert(title: "Server Error", message: Strings.errorInvalidResponse)
            }
        })
        .catch({ error in
            DDLogError("Add contact error - \(error.localizedDescription)")
            self.alertPresenter.errorAlert(title: "Add Contact Error", message: Strings.errorRequestFailed)
        })
        
    }
    
    func addWhitelistEntry(publicId: String, directoryId: String?) throws {

        if ContactsModel.instance.whitelistIdExists(publicId: publicId) {
            throw ContactError(error: "Whitelist ID \(publicId) exists")
        }
        let request = UpdateWhitelistRequest(id: publicId, action: "add")
//        let delegate = UpdateWhitelistDelegate(request: request, updateType: .addEntry)
//        delegate.publicId = publicId
//        delegate.directoryId = directoryId
//        let addTask = EnclaveTask<UpdateWhitelistRequest, UpdateWhitelistResponse>(delegate: delegate)
//        addTask.errorTitle = "Permitted ID List Error"
//        addTask.sendRequest(request)
        
    }
    
    func deleteContact(publicId: String) {
        
        let request = DeleteContactRequest(publicId: publicId)
        let deleteTask = EnclaveTask<DeleteContactRequest, DeleteContactResponse>()
        deleteTask.sendRequest(request: request)
        .then({ response in
            // If there are duplicates in the database, this will prevent crashes
            // However, duplicates will require two separate deletes
            let result = response.result ?? "invalid response"
            DDLogInfo("Delete contact result: \(result)")
            if let contact = ContactsModel.instance.getContact(publicId: response.publicId!) {
                ContactsModel.instance.deleteContact(contact: contact)
                MessageManager().clearMessages(contactId: contact.contactId)
                NotificationCenter.default.post(name: Notifications.ContactDeleted, object: contact.publicId)
            }
            else {
                DDLogError("Contact doesn't exist in local database")
            }
        })
        .catch({ error in
            DDLogError("Delete contact error: \(error.localizedDescription)")
            self.alertPresenter.errorAlert(title: "Contact Error", message: Strings.errorRequestFailed)
        })
        
    }

    func deleteWhitelistEntry(publicId: String) {

        let request = UpdateWhitelistRequest(id: publicId, action: "delete")
//        let delegate = UpdateWhitelistDelegate(request: request, updateType: .deleteEntry)
//        delegate.publicId = publicId
//        let addTask = EnclaveTask<UpdateWhitelistRequest, UpdateWhitelistResponse>(delegate: delegate)
//        addTask.errorTitle = "Permitted Contact List Error"
//        addTask.sendRequest(request)

    }
    
    func getPendingRequests() {
        
        let getTask = EnclaveTask<GetPendingRequests, GetPendingRequestsResponse>()
        getTask.sendRequest(request: GetPendingRequests())
            .then({ response in
                // Notifies account session to proceed with status updates
                AsyncNotifier.notify(name: Notifications.GetRequestsComplete, object: nil)
                if let error = response.error {
                    DDLogError("Error while updating pending requests - \(error)")
                } else {
                    guard let requests = response.serverRequests else { return }
                    DDLogInfo("\(requests.count) pending requests returned")
                    if requests.count > 0 {
                        ContactsModel.instance.addRequests(requests: requests)
                        NotificationCenter.default.post(name: Notifications.SetContactBadge, object: nil)
                    }
                    else {
                        ContactsModel.instance.clearRequests()
                    }
                    NotificationCenter.default.post(name: Notifications.RequestsUpdated,
                                                    object: ContactsModel.instance.pendingRequests.count)
                }
            })
            .catch({error in
                AsyncNotifier.notify(name: Notifications.GetRequestsComplete, object: nil)
                DDLogError("Get pending requests error: \(error.localizedDescription)")
            })
        
    }
    
    func getRequestStatus() {
        
        var pending = [String]()
        for contact in ContactsModel.instance.pendingContactList {
            pending.append(contact.publicId)
        }
        
        let request = GetRequestStatusRequest(requestedIds: pending)
        let updateTask = EnclaveTask<GetRequestStatusRequest, GetRequestStatusResponse>()
        updateTask.sendRequest(request: request)
        .then({ response in
            AsyncNotifier.notify(name: Notifications.GetStatusComplete, object: nil)
            if let error = response.error {
                DDLogError("Error while updating contact status - \(error)")
            } else {
                guard let contacts = response.contacts else { return }
                if contacts.count > 0 {
                    do {
                        let updates = try ContactsModel.instance.contactsAcknowledged(serverContacts: response.contacts!)
                        print("\(updates.count) contacts updated")
                        NotificationCenter.default.post(name: Notifications.RequestStatusUpdated, object: updates)
                        NotificationCenter.default.post(name: Notifications.SetContactBadge, object: nil)
                        print("Status updated on \(updates.count) requests")
                    }
                    catch {
                        DDLogError("Error updating contacts: \(error)")
                    }
                }
                else {
                    DDLogInfo("No request status updates")
                }
            }

        })
        .catch({ error in
            AsyncNotifier.notify(name: Notifications.GetStatusComplete, object: nil)
            DDLogError("Get request status error: \(error.localizedDescription)")
        })
        
    }

    func hideContact(_ contact: Contact) {
        
        let request = SetContactStatusRequest(publicId: sessionState.publicId!, status: "ignored")
    }
    
    func matchDirectoryId(directoryId: String?, publicId: String?) {

        let request = MatchDirectoryIdRequest(publicId: publicId, directoryId: directoryId)
//        let delegate = MatchDirectoryIdDelegate(request: request)
//        let matchTask = EnclaveTask<MatchDirectoryIdRequest, MatchDirectoryIdResponse>(delegate: delegate)
//        matchTask.errorTitle = "Directory ID Error"
//        matchTask.sendRequest(request)
        
    }

    func setContactPolicy(_ policy: String) {
        
        let request = SetContactPolicyRequest(policy: policy)
        let setTask = EnclaveTask<SetContactPolicyRequest, SetContactPolicyResponse>()
        setTask.sendRequest(request: request)
            .then( { response in
                NotificationCenter.default.post(name: Notifications.PolicyUpdated, object: response)
            })
            .catch( { error in
                DDLogError("Set contact policy error - \(error.localizedDescription)")
                self.alertPresenter.errorAlert(title: "Contact Policy Error", message: Strings.errorRequestFailed)
            })
        
    }

    func showContact(_ contact: Contact) {
        
    }
/*
    func syncContacts(contacts: [Contact], action: String) {

        let syncRequest = SyncContactsRequest()
        for contact in contacts {
            syncRequest.contacts?.append(SyncContact(contact: contact, action: "add"))
        }
        let delegate = SyncContactsDelegate(request: syncRequest)
        let setTask = EnclaveTask<SyncContactsRequest, SyncContactsResponse>(delegate: delegate)
        setTask.errorTitle = "Contact Sync Error"
        setTask.sendRequest(syncRequest)

    }
*/
    func updateDirectoryId(newDirectoryId: String?, oldDirectoryId: String?) {

        let request = SetDirectoryIdRequest(oldDirectoryId: oldDirectoryId ?? "", newDirectoryId: newDirectoryId ?? "")
        let delegate = SetDirectoryIdDelegate(request: request)
//        let setTask = EnclaveTask<SetDirectoryIdRequest, SetDirectoryIdResponse>(delegate: delegate)
//        setTask.errorTitle = "Directory ID Error"
//        setTask.sendRequest(request)
        
    }

}

// Debug only
extension ContactManager {

    func deleteServerContact(directoryId: String) {

        NotificationCenter.default.addObserver(self, selector: #selector(directoryIdMatched(_:)),
                                               name: Notifications.DirectoryIdMatched, object: nil)
        
        matchDirectoryId(directoryId: directoryId, publicId: nil)

    }

    @objc func directoryIdMatched(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.DirectoryIdMatched, object: nil)
        guard let response = notification.object as? MatchDirectoryIdResponse else { return }
        if response.result == "found" {
            deleteContact(publicId: response.publicId!)
        }
        else {
            print("Delete contact error: Directory ID not found")
            //alertPresenter.errorAlert(title: "Delete Contact Error", message: "That directory ID doesn't exist")
        }

    }

}
