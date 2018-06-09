//
//  ContactManager.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/10/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

struct ContactRequest: Hashable {

    var nickname: String?
    var publicId: String
    var hashValue: Int {
        return publicId.hashValue
    }

    init(publicId: String, nickname: String?) {

        self.publicId = publicId
        self.nickname = nickname

    }

    init?(request: [String: String]) {

        guard let puid = request["publicId"] else { return nil }
        publicId = puid
        nickname = request["nickname"]

    }

    static func ==(lhs: ContactRequest, rhs: ContactRequest) -> Bool {
        return lhs.publicId == rhs.publicId
    }

}

class ContactManager: NSObject {

    static private var contactSet = Set<Contact>()
    static private var contactMap = [String: Contact]()
    static private var contactIdMap = [Int: Contact]()
    static private var requestSet = Set<ContactRequest>()
    static private var initialized = false

    var contactDatabase = ContactDatabase()
    var sessionState = SessionState()
    var config = Configurator()
    var pendingRequests: Set<ContactRequest> {
        loadContacts()
        return ContactManager.requestSet
    }
    var contactList: [Contact] {
        loadContacts()
        return Array(ContactManager.contactSet)
    }
    var alertPresenter = AlertPresenter()
 
    override init() {

        contactDatabase = ContactDatabase()

        super.init()

        
    }

    func acknowledgeRequest(contactRequest: ContactRequest, response: String) {

        let request = AcknowledgeRequest(id: contactRequest.publicId, response: response)
        let delegate = AcknowledgeRequestDelegate(request: request, contactRequest: contactRequest)
        let ackTask = EnclaveTask<AcknowledgeRequest, AcknowledgeRequestResponse>(delegate: delegate)
        ackTask.errorTitle = "Contact Error"
        ackTask.sendRequest(request)

    }

    func addContact(_ contact: Contact) {

        if ContactManager.contactMap[contact.publicId] != nil {
            alertPresenter.errorAlert(title: "Contact Error", message: "Attempted to add duplicate contact")
        }
        else {
            contact.contactId = config.newContactId()
            contactDatabase.add(contact)
            ContactManager.contactMap[contact.publicId] = contact
            ContactManager.contactIdMap[contact.contactId] = contact
            ContactManager.contactSet.insert(contact)
        }
        
    }
    
    func addFriend(_ publicId:String) -> Bool {

        let found = config.whitelistIndexOf(publicId)
        if found == NSNotFound {
            let request = UpdateWhitelistRequest(id: publicId, action: "add")
            let delegate = UpdateWhitelistDelegate(request: request, updateType: .addFriend)
            let addTask = EnclaveTask<UpdateWhitelistRequest, UpdateWhitelistResponse>(delegate: delegate)
            addTask.errorTitle = "Friends List Error"
            addTask.sendRequest(request)
            return true
        }
        else {
            return false
        }

    }

    func addRequests(_ requests: [[String: String]]) {

        var newRequests = [[String: String]]()
        for request in requests {
            if let contactRequest = ContactRequest(request: request) {
                ContactManager.requestSet.insert(contactRequest)
                newRequests.append(request)
            }
        }
        if !newRequests.isEmpty {
            contactDatabase.addContactRequests(newRequests)
        }

    }

    func allContactIds() -> [Int] {

        var allIds = [Int]()
        for contact in ContactManager.contactSet {
            allIds.append(contact.contactId)
        }
        return allIds

    }

    @objc func clearContacts() {

        ContactManager.contactSet.removeAll()
        ContactManager.contactMap.removeAll()
        ContactManager.contactIdMap.removeAll()
        ContactManager.initialized = false

    }

    func clearRequests() {

        ContactManager.requestSet.removeAll()

    }

    func deleteContact(publicId: String) {
        
        let request = DeleteContactRequest(publicId: publicId)
        let delegate = DeleteContactDelegate(request: request)
        let deleteTask = EnclaveTask<DeleteContactRequest, DeleteContactResponse>(delegate: delegate)
        deleteTask.errorTitle = "Contact Error"
        deleteTask.sendRequest(request)
        
    }

    func deleteContact(contact: Contact) {
        
        self.contactDatabase.deleteContact(contact.contactId)
        ContactManager.contactMap.removeValue(forKey: contact.publicId)
        ContactManager.contactSet.remove(contact)

    }
    
    func deleteContactRequest(_ contactRequest: ContactRequest) {
        
        ContactManager.requestSet.remove(contactRequest)
        self.contactDatabase.deleteContactRequest(contactRequest.publicId)

    }

    func deleteFriend(_ publicId: String) {

        let request = UpdateWhitelistRequest(id: publicId, action: "delete")
        let delegate = UpdateWhitelistDelegate(request: request, updateType: .deleteFriend)
        let addTask = EnclaveTask<UpdateWhitelistRequest, UpdateWhitelistResponse>(delegate: delegate)
        addTask.errorTitle = "Friends List Error"
        addTask.sendRequest(request)

    }
    
    @objc func getContact(publicId: String) -> Contact? {

        return ContactManager.contactMap[publicId]

    }

    @objc func getContact(contactId: Int) -> Contact? {

        return ContactManager.contactIdMap[contactId]

    }

    func getContactId(_ publicId: String) -> Int {

        if let contact = ContactManager.contactMap[publicId] {
            return contact.contactId
        }
        else {
            return NSNotFound
        }

    }

    @objc func getPendingRequests() {
        
        let request = GetPendingRequests()
        let delegate = GetPendingRequestsDelegate(request: request)
        let getTask = EnclaveTask<GetPendingRequests, GetPendingRequestsResponse>(delegate: delegate)
        getTask.errorTitle = "Contact Error"
        getTask.sendRequest(request)
        
    }
    
    @objc func getRequestStatus(retry: Bool, publicId: String) {
        
        var pending = [String]()
        if retry {
            pending.append(publicId)
        }
        else {
            for contact in ContactManager.contactSet {
                if contact.status == "pending" {
                    pending.append(contact.publicId)
                }
            }
        }
        
        let request = GetRequestStatusRequest(requestedIds: pending)
        let delegate = GetRequestStatusDelegate(request: request, publicId: publicId, retry: retry)
        let updateTask = EnclaveTask<GetRequestStatusRequest, GetRequestStatusResponse>(delegate: delegate)
        updateTask.errorTitle = "Contact Error"
        updateTask.sendRequest(request)
        
    }

    func loadContacts() {

        if (sessionState.authenticated && !ContactManager.initialized) {
            ContactManager.initialized = true
            let list = contactDatabase.getContactList()
            for contact in list {
                ContactManager.contactSet.insert(contact)
            }
            let requests = contactDatabase.getContactRequests()
            for request in requests {
                if let contactRequest = ContactRequest(request: request) {
                    ContactManager.requestSet.insert(contactRequest)
                }
            }
            mapContacts()
        }

    }

    func mapContacts() {
        
        ContactManager.contactMap.removeAll()
        for contact in ContactManager.contactSet {
            ContactManager.contactMap[contact.publicId] = contact
            ContactManager.contactIdMap[contact.contactId] = contact
        }
        
    }
    
    @objc func matchNickname(nickname: String?, publicId: String?) {

        let request = MatchNicknameRequest(publicId: publicId, nickname: nickname)
        let delegate = MatchNicknameDelegate(request: request)
        let matchTask = EnclaveTask<MatchNicknameRequest, MatchNicknameResponse>(delegate: delegate)
        matchTask.errorTitle = "Nickname Error"
        matchTask.sendRequest(request)
        
    }

    func requestContact(publicId: String, nickname: String?, retry: Bool) {

        if ContactManager.contactMap[publicId] != nil && !retry {
            alertPresenter.errorAlert(title: "ContactError", message: "This contact already exists in your contact list")
        }
        else {
            let request = RequestContactRequest(id: publicId, retry: retry)
            let delegate = RequestContactDelegate(request: request, retry: retry, nickname: nickname)
            let reqTask = EnclaveTask<RequestContactRequest, RequestContactResponse>(delegate: delegate)
            reqTask.errorTitle = "Contact Error"
            reqTask.sendRequest(request)
        }
        
    }

    func searchContacts(_ fragment:String) -> [Contact] {

        var result = [Contact]()
        for contact in ContactManager.contactSet {
            let pCompare = contact.publicId.uppercased()
            if (pCompare.contains(fragment)) {
                result.append(contact)
            }
            else if let nickname = contact.nickname {
                let nCompare = nickname.uppercased()
                if (nCompare.contains(fragment)) {
                    result.append(contact)
                }
            }
        }
        return result

    }

    @objc func setContactPolicy(_ policy: String) {
        
        let request = SetContactPolicyRequest(policy: policy)
        let delegate = SetContactPolicyDelegate(request: request)
        let setTask = EnclaveTask<SetContactPolicyRequest, SetContactPolicyResponse>(delegate: delegate)
        setTask.errorTitle = "Policy Error"
        setTask.sendRequest(request)
        
    }

    func updateContact(_ update: Contact) {

        contactDatabase.update([update])
        ContactManager.contactMap[update.publicId] = update
        ContactManager.contactSet.update(with: update)

    }

    func updateContacts(_ serverContacts: [ServerContact]) -> [Contact] {

        var updates = [Contact]()

        for serverContact in serverContacts {
            if serverContact.status == "accepted" {
                if let contact = ContactManager.contactMap[serverContact.publicId!] {
                    contact.status = serverContact.status!
                    contact.timestamp = Int64(serverContact.timestamp!)
                    contact.authData = Data(base64Encoded: serverContact.authData!)
                    contact.nonce = Data(base64Encoded: serverContact.nonce!)
                    var messageKeys = [Data]()
                    for key in serverContact.messageKeys! {
                        messageKeys.append(Data(base64Encoded: key)!)
                    }
                    contact.messageKeys = messageKeys
                    updates.append(contact)
                }
                else {
                    alertPresenter.errorAlert(title: "Contact Error", message: "Updated contact not found")
                }
            }
        }
        contactDatabase.update(updates)
        return updates

    }

    @objc func updateNickname(newNickname: String?, oldNickname: String?) {

        let request = SetNicknameRequest(oldNickname: oldNickname ?? "", newNickname: newNickname ?? "")
        let delegate = SetNicknameDelegate(request: request)
        let setTask = EnclaveTask<SetNicknameRequest, SetNicknameResponse>(delegate: delegate)
        setTask.errorTitle = "Nickname Error"
        setTask.sendRequest(request)
        
    }
    
}

// Debug only
extension ContactManager {

    func deleteServerContact(nickname: String) {

        NotificationCenter.default.addObserver(self, selector: #selector(nicknameMatched(_:)),
                                               name: Notifications.NicknameMatched, object: nil)
        
        matchNickname(nickname: nickname, publicId: nil)

    }

    @objc func nicknameMatched(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.NicknameMatched, object: nil)
        guard let response = notification.object as? MatchNicknameResponse else { return }
        if response.result == "found" {
            deleteContact(publicId: response.publicId!)
        }
        else {
            alertPresenter.errorAlert(title: "Delete Contact Error", message: "That nickname doesn't exist")
        }

    }

}
