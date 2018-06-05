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

    var contactDatabase: ContactDatabase
    var config = Configurator()
    var pendingRequests: Set<ContactRequest> {
        return ContactManager.requestSet
    }
    var contactList: [Contact] {
        return Array(ContactManager.contactSet)
    }
    var alertPresenter = AlertPresenter()
 
    override init() {

        contactDatabase = ContactDatabase()

        super.init()

        let sessionState = SessionState()
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

    func acknowledgeRequest(contactRequest: ContactRequest, response: String) {

        let request = AcknowledgeRequest(id: contactRequest.publicId, response: response)
        let ackTask = EnclaveTask<AcknowledgeRequestResponse>({ (response: AcknowledgeRequestResponse) -> Void in
            if let acknowledged = Contact(serverContact: response.acknowledged!),
                acknowledged.publicId == contactRequest.publicId {
                acknowledged.nickname = contactRequest.nickname
                self.addContact(acknowledged)
                ContactManager.requestSet.remove(contactRequest)
                self.contactDatabase.deleteContactRequest(acknowledged.publicId)
                DispatchQueue.global().async {
                    NotificationCenter.default.post(name: Notifications.RequestAcknowledged, object: acknowledged)
                }
            }
            else {
                self.alertPresenter.errorAlert(title: "Contact Error",
                                               message: "Invalid response to acknowledgement")
            }
        })
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
            let addTask = EnclaveTask<UpdateWhitelistResponse>({ (response: UpdateWhitelistResponse) -> Void in
                if  response.action == "add", response.result == "added" || response.result == "exists" {
                    NotificationCenter.default.post(name: Notifications.FriendAdded, object: response)
                }
                else {
                    self.alertPresenter.errorAlert(title: "Friends List Error",
                                                   message: "Invalid response from server")
                }
            })
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

    func deleteContact(_ publicId: String) {
        
        let request = DeleteContactRequest(publicId: publicId)
        let deleteTask = EnclaveTask<DeleteContactResponse>({ (response: DeleteContactResponse) -> Void in
            // If there are duplicates in the database, this will prevent crashes
            // However, duplicates will require two separate deletes
            if let contactId = ContactManager.contactMap[response.publicId!]?.contactId,
                response.result == "deleted" {
                self.contactDatabase.deleteContact(contactId)
                ContactManager.contactMap.removeValue(forKey: publicId)
                let messageDatabase = MessagesDatabase()
                messageDatabase.clearMessages(contactId)
                var newSet = Set<Contact>()
                for contact in ContactManager.contactSet {
                    if contact.publicId != publicId {
                        newSet.insert(contact)
                    }
                }
                ContactManager.contactSet = newSet
                NotificationCenter.default.post(name: Notifications.ContactDeleted, object: publicId)
                NotificationCenter.default.post(name: Notifications.MessagesUpdated, object: nil)
            }
        })
        deleteTask.errorTitle = "Contact Error"
        deleteTask.sendRequest(request)
        
    }

    func deleteFriend(_ publicId: String) {

        let request = UpdateWhitelistRequest(id: publicId, action: "delete")
        let addTask = EnclaveTask<UpdateWhitelistResponse>({ (response: UpdateWhitelistResponse) -> Void in
            if  response.action == "delete", response.result == "deleted" || response.result == "not found" {
                NotificationCenter.default.post(name: Notifications.FriendDeleted, object: nil)
            }
            else {
                self.alertPresenter.errorAlert(title: "Friends List Error",
                                               message: "Invalid response from server")
            }
        })
        addTask.errorTitle = "Friends List Error"
        addTask.sendRequest(request)

    }
    
    @objc func getContact(_ publicId: String) -> Contact? {

        return ContactManager.contactMap[publicId]

    }

    @objc func getContactById(_ contactId: Int) -> Contact? {

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
        let getTask = EnclaveTask<GetPendingRequestsResponse>({ (response: GetPendingRequestsResponse) -> Void in
            print("\(response.requests!.count) pending requests returned")
            if response.requests!.count > 0 {
                self.addRequests(response.requests!)
            }
            else {
                ContactManager.requestSet.removeAll()
            }
            DispatchQueue.global().async {
                NotificationCenter.default.post(name: Notifications.RequestsUpdated,
                                                object: ContactManager.requestSet.count)
            }
        })
        getTask.errorTitle = "Contact Error"
        getTask.sendRequest(request)
        
    }
    
    @objc func getRequestStatus(retry: Bool, publicId: String?) {
        
        var pending = [String]()
        if retry {
            pending.append(publicId!)
        }
        else {
            for contact in ContactManager.contactSet {
                if contact.status == "pending" {
                    pending.append(contact.publicId)
                }
            }
        }
        
        let request = GetRequestStatusRequest(requestedIds: pending)
        let updateTask = EnclaveTask<GetRequestStatusResponse>({ (response: GetRequestStatusResponse) -> Void in
            if response.contacts!.count > 0 {
                let updated = self.updateContacts(response.contacts!)
                NotificationCenter.default.post(name: Notifications.RequestStatusUpdated, object: updated)
                print("\(updated.count) contacts updated")
            }
            else if retry {
                self.requestContact(publicId: publicId!, nickname: nil, retry: true)
            }
        })
        updateTask.errorTitle = "Contact Error"
        updateTask.sendRequest(request)
        
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
        let matchTask = EnclaveTask<MatchNicknameResponse>({ (response: MatchNicknameResponse) -> Void in
            NotificationCenter.default.post(name: Notifications.NicknameMatched, object: response)
        })
        matchTask.errorTitle = "Nickname Error"
        matchTask.sendRequest(request)
        
    }

    func requestContact(publicId: String, nickname: String?, retry: Bool) {

        let request = RequestContactRequest(id: publicId, retry: retry)
        if ContactManager.contactMap[publicId] != nil && !retry {
            alertPresenter.errorAlert(title: "ContactError", message: "This contact already exists in your contact list")
        }
        else {
            let reqTask = EnclaveTask<RequestContactResponse>({ (response: RequestContactResponse) -> Void in
                if !retry {
                    let contact = Contact()
                    contact.publicId = response.requestedContactId!
                    contact.nickname = nickname
                    contact.status = response.result!
                    self.addContact(contact)
                    NotificationCenter.default.post(name: Notifications.ContactRequested, object: contact)
                }
            })
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
        let setTask = EnclaveTask<SetContactPolicyResponse>({ (response: SetContactPolicyResponse) -> Void in
            NotificationCenter.default.post(name: Notifications.PolicyUpdated, object: response)
        })
        setTask.errorTitle = "Policy Error"
        setTask.sendRequest(request)
        
    }

    @objc func updateNickname(newNickname: String?, oldNickname: String?) {

        let request = SetNicknameRequest(oldNickname: oldNickname ?? "", newNickname: newNickname ?? "")
        let setTask = EnclaveTask<SetNicknameResponse>({ (response: SetNicknameResponse) -> Void in
            NotificationCenter.default.post(name: Notifications.NicknameUpdated, object: response)
        })
        setTask.errorTitle = "Nickname Error"
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
            deleteContact(response.publicId!)
        }
        else {
            alertPresenter.errorAlert(title: "Delete Contact Error", message: "That nickname doesn't exist")
        }

    }

}
