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
    
    func acknowledgeRequest(contactRequest: ContactRequest, response: String) {

        let request = AcknowledgeRequest(requestingId: contactRequest.publicId, response: response)
        let delegate = AcknowledgeRequestDelegate(request: request, contactRequest: contactRequest)
        let ackTask = EnclaveTask<AcknowledgeRequest, AcknowledgeRequestResponse>(delegate: delegate)
        ackTask.errorTitle = "Contact Error"
        ackTask.sendRequest(request)

    }

    func addWhitelistEntry(publicId: String, directoryId: String?) throws {

        if ContactsModel.instance.whitelistIdExists(publicId: publicId) {
            throw ContactError(error: "Whitelist ID \(publicId) exists")
        }
        let request = UpdateWhitelistRequest(id: publicId, action: "add")
        let delegate = UpdateWhitelistDelegate(request: request, updateType: .addEntry)
        delegate.publicId = publicId
        delegate.directoryId = directoryId
        let addTask = EnclaveTask<UpdateWhitelistRequest, UpdateWhitelistResponse>(delegate: delegate)
        addTask.errorTitle = "Permitted ID List Error"
        addTask.sendRequest(request)
        
    }
    
    func deleteContact(publicId: String) {
        
        let request = DeleteContactRequest(publicId: publicId)
        let delegate = DeleteContactDelegate(request: request)
        let deleteTask = EnclaveTask<DeleteContactRequest, DeleteContactResponse>(delegate: delegate)
        deleteTask.errorTitle = "Contact Error"
        deleteTask.sendRequest(request)
        
    }

    func deleteWhitelistEntry(publicId: String) {

        let request = UpdateWhitelistRequest(id: publicId, action: "delete")
        let delegate = UpdateWhitelistDelegate(request: request, updateType: .deleteEntry)
        delegate.publicId = publicId
        let addTask = EnclaveTask<UpdateWhitelistRequest, UpdateWhitelistResponse>(delegate: delegate)
        addTask.errorTitle = "Permitted Contact List Error"
        addTask.sendRequest(request)

    }
    
    func getPendingRequests() {
        
        let request = GetPendingRequests()
        let delegate = GetPendingRequestsDelegate(request: request)
        let getTask = EnclaveTask<GetPendingRequests, GetPendingRequestsResponse>(delegate: delegate)
        getTask.errorTitle = "Contact Error"
        getTask.sendRequest(request)
        
    }
    
    func getRequestStatus() {
        
        var pending = [String]()
        for contact in ContactsModel.instance.pendingContactList {
            pending.append(contact.publicId)
        }
        
        let request = GetRequestStatusRequest(requestedIds: pending)
        let delegate = GetRequestStatusDelegate(request: request /*, publicId: publicId, retry: retry */)
        let updateTask = EnclaveTask<GetRequestStatusRequest, GetRequestStatusResponse>(delegate: delegate)
        updateTask.errorTitle = "Contact Error"
        updateTask.sendRequest(request)
        
    }

    func hideContact(_ contact: Contact) {
        
        let request = SetContactStatusRequest(publicId: sessionState.publicId!, status: "ignored")
    }
    
    func matchDirectoryId(directoryId: String?, publicId: String?) {

        let request = MatchDirectoryIdRequest(publicId: publicId, directoryId: directoryId)
        let delegate = MatchDirectoryIdDelegate(request: request)
        let matchTask = EnclaveTask<MatchDirectoryIdRequest, MatchDirectoryIdResponse>(delegate: delegate)
        matchTask.errorTitle = "Directory ID Error"
        matchTask.sendRequest(request)
        
    }

    // Assumes existing contact validation has been done
    func addContactRequest(publicId: String?, directoryId: String?, initialMessage: String?) {
        
        let request = AddContactRequest(publicId: publicId, directoryId: directoryId, initialMessage: initialMessage)
        let delegate = AddContactDelegate(request: request)
        let reqTask = EnclaveTask<AddContactRequest, AddContactResponse>(delegate: delegate)
        reqTask.errorTitle = "Contact Error"
        reqTask.sendRequest(request)
        
    }

    func setContactPolicy(_ policy: String) {
        
        let request = SetContactPolicyRequest(policy: policy)
        let delegate = SetContactPolicyDelegate(request: request)
        let setTask = EnclaveTask<SetContactPolicyRequest, SetContactPolicyResponse>(delegate: delegate)
        setTask.errorTitle = "Policy Error"
        setTask.sendRequest(request)
        
    }

    func showContact(_ contact: Contact) {
        
    }
    
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

    func updateDirectoryId(newDirectoryId: String?, oldDirectoryId: String?) {

        let request = SetDirectoryIdRequest(oldDirectoryId: oldDirectoryId ?? "", newDirectoryId: newDirectoryId ?? "")
        let delegate = SetDirectoryIdDelegate(request: request)
        let setTask = EnclaveTask<SetDirectoryIdRequest, SetDirectoryIdResponse>(delegate: delegate)
        setTask.errorTitle = "Directory ID Error"
        setTask.sendRequest(request)
        
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
