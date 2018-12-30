//
//  ContactManager.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/10/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation
import CocoaLumberjack

class ContactManager: NSObject {

    var sessionState = SessionState.instance
    var config = Configurator()
    var contactsModel = ContactsModel.instance
    
    func acknowledgeRequest(publicId: String, response: String,
                            onResponse: @escaping (AcknowledgeRequestResponse) -> Void,
                            onError: @escaping (String) -> Void) throws {

        let request = AcknowledgeRequest(requestingId: publicId, response: response)
        let requester = EnclaveRequester<AcknowledgeRequestResponse>(onResponse: { response -> Void in
                                                                        onResponse(response) },
                                                                     onError: { error in
                                                                        onError(error) })
        try requester.doRequest(request: request)

    }

    func addWhitelistEntry(publicId: String, directoryId: String?) throws {

        if contactsModel.whitelistIdExists(publicId: publicId) {
            DDLogError("Whitelist ID \(publicId) exists")
            throw WhitelistError.idExists        }
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
    
    func getPendingRequests(onResponse: @escaping (GetPendingRequestsResponse) -> Void,
                            onError: @escaping (String) -> Void) throws {
        
        let request = GetPendingRequests()
        let requester = EnclaveRequester<GetPendingRequestsResponse>(onResponse: { response -> Void in
            onResponse(response) },
                                                                     onError: { error in
                                                                        onError(error) })
        try requester.doRequest(request: request)
        
    }
    
    func getRequestStatus(/* retry: Bool, publicId: String? */) {
        
        var pending = [String]()
        let pendingContacts = contactsModel.pendingContactList
        for contact in pendingContacts {
            // Contact IDs are always present in pending contacts
            pending.append(contact.publicId!)
        }
        
        let request = GetRequestStatusRequest(requestedIds: pending)
        let delegate = GetRequestStatusDelegate(request: request /*, publicId: publicId, retry: retry */)
        let updateTask = EnclaveTask<GetRequestStatusRequest, GetRequestStatusResponse>(delegate: delegate)
        updateTask.errorTitle = "Contact Error"
        updateTask.sendRequest(request)
        
    }
/*
    func matchDirectoryId(directoryId: String?, publicId: String?) {

        let request = MatchDirectoryIdRequest(publicId: publicId, directoryId: directoryId)
        let delegate = MatchDirectoryIdDelegate(request: request)
        let matchTask = EnclaveTask<MatchDirectoryIdRequest, MatchDirectoryIdResponse>(delegate: delegate)
        matchTask.errorTitle = "Directory ID Error"
        matchTask.sendRequest(request)
        
    }
*/
    func requestContact(contact: Contact, retry: Bool, onResponse: @escaping (AddContactResponse) -> Void,
                        onError: @escaping (String) -> Void) throws {

        // We can only check for duplicate public IDs here
        if let publicId = contact.publicId,
            let _ = contactsModel.getContact(publicId: publicId), !retry {
            throw ContactError.duplicateContact
        }

        let request = AddContactRequest(contact: contact, retry: retry)
        let requester = EnclaveRequester<AddContactResponse>(onResponse: { response -> Void in onResponse(response) },
                                                             onError: { error in onError(error) })
        try requester.doRequest(request: request)

    }

    func setContactPolicy(_ policy: String) {
        
        let request = SetContactPolicyRequest(policy: policy)
        let delegate = SetContactPolicyDelegate(request: request)
        let setTask = EnclaveTask<SetContactPolicyRequest, SetContactPolicyResponse>(delegate: delegate)
        setTask.errorTitle = "Policy Error"
        setTask.sendRequest(request)
        
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
/*
    func updateDirectoryId(newDirectoryId: String?, oldDirectoryId: String?) {

        let request = SetDirectoryIdRequest(oldDirectoryId: oldDirectoryId ?? "", newDirectoryId: newDirectoryId ?? "")
        let delegate = SetDirectoryIdDelegate(request: request)
        let setTask = EnclaveTask<SetDirectoryIdRequest, SetDirectoryIdResponse>(delegate: delegate)
        setTask.errorTitle = "Directory ID Error"
        setTask.sendRequest(request)
        
    }
*/
}

// Debug only
extension ContactManager {
/*
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
*/
}
