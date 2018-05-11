//
//  ContactManager.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/10/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import RKDropdownAlert
import ChameleonFramework

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

    init?(serverRequest: [AnyHashable: Any]) {

        guard let puid = serverRequest["publicId"] as? String else { return nil }
        publicId = puid
        nickname = serverRequest["nickname"] as? String

    }

    static func ==(lhs: ContactRequest, rhs: ContactRequest) -> Bool {
        return lhs.publicId == rhs.publicId
    }

}

class ContactManager: NSObject {

    static private var contactList = [Contact]()
    static private var contactMap = [String: Contact]()
    static private var contactIdMap = [Int: Contact]()
    static private var requestSet = Set<ContactRequest>()
    static private var initialized = false

    var contactDatabase: ContactDatabase
    var config = Configurator()
    var pendingRequests: Set<ContactRequest> {
        return ContactManager.requestSet
    }
 
    override init() {

        contactDatabase = ContactDatabase()

        super.init()

        let sessionState = SessionState()
        if (sessionState.authenticated && !ContactManager.initialized) {
            ContactManager.initialized = true
            ContactManager.contactList = contactDatabase.getContactList()
            mapContacts()
        }
        
    }

    func acknowledgeRequest(contactRequest: ContactRequest, response: String) {

        var request = [AnyHashable: Any]()
        request["method"] = "AcknowledgeRequest"
        request["id"] = contactRequest.publicId
        request["response"] = response
        let ackTask = EnclaveTask({ (response: [AnyHashable: Any]) -> Void in
            if let serverContact = response["acknowledged"] as? [AnyHashable: Any],
                let acknowledged = ContactRequest(serverRequest: serverContact),
                acknowledged == contactRequest,
                let contact = Contact(serverContact: serverContact) {
                contact.nickname = contactRequest.nickname
                self.addContact(contact)
                ContactManager.requestSet.remove(contactRequest)
                DispatchQueue.global().async {
                    NotificationCenter.default.post(name: Notifications.RequestAcknowledged, object: nil)
                }
            }
            else {
                var info = [AnyHashable: Any]()
                info["title"] = "Contact Error"
                info["message"] = "Invalid response to acknowledgement"
                NotificationCenter.default.post(name: Notifications.PresentAlert, object: nil, userInfo: info)
            }
        })
        ackTask.errorTitle = "Contact Error"
        ackTask.sendRequest(request)

    }

    func addContact(_ contact: Contact) {

        if ContactManager.contactMap[contact.publicId] != nil {
            var info = [AnyHashable:Any]()
            info["title"] = "Contact Error"
            info["message"] = "Attempted to add duplicate contact"
            NotificationCenter.default.post(name: Notifications.PresentAlert, object: nil, userInfo: info)
        }
        else {
            contact.contactId = config.newContactId()
            contactDatabase.add(contact)
            ContactManager.contactMap[contact.publicId] = contact
            ContactManager.contactIdMap[contact.contactId] = contact
            ContactManager.contactList.append(contact)
        }
        
    }
    
    func addFriend(_ publicId:String) -> Bool {

        let found = config.whitelistIndex(of: publicId)
        if found == NSNotFound {
            var request = [AnyHashable: Any]()
            request["method"] = "UpdateWhitelist"
            request["id"] = publicId
            request["action"] = "add"
            let addTask = EnclaveTask({ (response: [AnyHashable: Any]) -> Void in
                NotificationCenter.default.post(name: Notifications.FriendAdded, object: nil, userInfo: response)
            })
            addTask.errorTitle = "Friends List Error"
            addTask.sendRequest(request)
            return true
        }
        else {
            return false
        }

    }

    // Returns true if new requests were added
    func addRequests(_ requests: [[AnyHashable: Any]]) {

        for request in requests {
            if let contactRequest = ContactRequest(serverRequest: request) {
                ContactManager.requestSet.insert(contactRequest)
            }
        }

    }

    func allContactIds() -> [Int] {

        var allIds = [Int]()
        for contact in ContactManager.contactList {
            allIds.append(contact.contactId)
        }
        return allIds

    }

    @objc func clearContacts() {

        ContactManager.contactList.removeAll()
        ContactManager.contactMap.removeAll()
        ContactManager.contactIdMap.removeAll()
        ContactManager.initialized = false

    }

    func deleteContact(_ publicId: String) {
        
        var request = [AnyHashable: Any]()
        request["method"] = "DeleteContact"
        request["publicId"] = publicId
        let deleteTask = EnclaveTask({ (response: [AnyHashable: Any]) -> Void in
            if let publicId = response["publicId"] as? String {
                // If there are duplicates in the database, this will prevent crashes
                // However, duplicates will require two separate deletes
                if let contactId = ContactManager.contactMap[publicId]?.contactId {
                    self.contactDatabase.deleteContact(contactId)
                    ContactManager.contactMap.removeValue(forKey: publicId)
                    let messageDatabase = MessagesDatabase()
                    messageDatabase.clearMessages(contactId)
                    var newList = [Contact]()
                    for contact in ContactManager.contactList {
                        if contact.publicId != publicId {
                            newList.append(contact)
                        }
                    }
                    ContactManager.contactList = newList
                    NotificationCenter.default.post(name: Notifications.ContactDeleted, object: publicId, userInfo: nil)
                    NotificationCenter.default.post(name: Notifications.MessagesUpdated, object: nil)
                }
            }
        })
        deleteTask.errorTitle = "Contact Error"
        deleteTask.sendRequest(request)
        
    }

    func deleteFriend(_ publicId: String) {

        var request = [AnyHashable: Any]()
        request["method"] = "UpdateWhitelist"
        request["id"] = publicId
        request["action"] = "delete"
        let deleteTask = EnclaveTask({ (response: [AnyHashable: Any]) -> Void in
                NotificationCenter.default.post(name: Notifications.FriendDeleted, object: nil, userInfo: response)
        })
        deleteTask.errorTitle = "Friends List Error"
        deleteTask.sendRequest(request)

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

    @objc func getContactList() -> [Contact] {
        return ContactManager.contactList
    }

    @objc func getPendingRequests() {

        var request = [AnyHashable: Any]()
        request["method"] = "GetPendingRequests"
        let getTask = EnclaveTask({ (response: [AnyHashable: Any]) -> Void in
            if let requests = response["requests"] as? [[AnyHashable: Any]] {
                print("\(requests.count) pending requests returned")
                if requests.count > 0 {
                    self.addRequests(requests)
                }
                else {
                    ContactManager.requestSet.removeAll()
                }
                DispatchQueue.global().async {
                    NotificationCenter.default.post(name: Notifications.RequestsUpdated,
                                                    object: ContactManager.requestSet.count)
                }
            }
            else {
                var info = [AnyHashable: Any]()
                info["title"] = "Contact Error"
                info["message"] = "Invalid response to get requests"
                NotificationCenter.default.post(name: Notifications.PresentAlert, object: nil, userInfo: info)
            }
        })
        getTask.errorTitle = "Contact Error"
        getTask.sendRequest(request)
        
    }

    func mapContacts() {
        
        ContactManager.contactMap.removeAll()
        for contact in ContactManager.contactList {
            ContactManager.contactMap[contact.publicId] = contact
            ContactManager.contactIdMap[contact.contactId] = contact
        }
        
    }
    
    @objc func matchNickname(nickname: String?, publicId: String?) {

        var request = [AnyHashable: Any]()
        request["method"] = "MatchNickname"
        if (nickname != nil) {
            request["nickname"] = nickname
        }
        if (publicId != nil) {
            request["publicId"] = publicId
        }
        let matchTask = EnclaveTask({ (response: [AnyHashable: Any]) -> Void in
            NotificationCenter.default.post(name: Notifications.NicknameMatched, object: nil, userInfo: response)
        })
        matchTask.errorTitle = "Nickname Error"
        matchTask.sendRequest(request)
        
    }

    func requestContact(publicId: String, nickname: String?) {

        var request = [AnyHashable: Any]()
        request["method"] = "RequestContact"
        request["id"] = publicId
        if let _ = ContactManager.contactMap[publicId] {
            var info = [AnyHashable: Any]()
            info["title"] = "Contact Error"
            info["message"] = "This contact already exists in your contact list"
            NotificationCenter.default.post(name: Notifications.PresentAlert, object: nil, userInfo: info)
        }
        else {
            let reqTask = EnclaveTask({ (response: [AnyHashable: Any]) -> Void in
                let contact = Contact()
                contact.publicId = response["requestedContactId"] as! String
                contact.nickname = nickname
                contact.status = response["result"] as! String
                self.addContact(contact)
                NotificationCenter.default.post(name: Notifications.ContactRequested, object: contact)
            })
            reqTask.errorTitle = "Contact Error"
            reqTask.sendRequest(request)
        }
        
    }

    func searchContacts(_ fragment:String) -> [Contact] {

        var result = [Contact]()
        for contact in ContactManager.contactList {
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
        
        var request = [AnyHashable: Any]()
        request["method"] = "SetContactPolicy"
        request["policy"] = policy
        let setTask = EnclaveTask({ (response: [AnyHashable: Any]) -> Void in
            NotificationCenter.default.post(name: Notifications.PolicyUpdated, object: nil, userInfo: response)
        })
        setTask.errorTitle = "Policy Error"
        setTask.sendRequest(request)
        
    }

    @objc func updateNickname(newNickname: String?, oldNickname: String?) {

        var request = [AnyHashable: Any]()
        request["method"] = "SetNickname"
        if (oldNickname != nil) {
            request["oldNickname"] = oldNickname
        }
        else {
            request["oldNickname"] = ""
        }
        if (newNickname != nil) {
            request["newNickname"] = newNickname
        }
        else {
            request["newNickname"] = ""
        }
        let setTask = EnclaveTask({ (response: [AnyHashable: Any]) -> Void in
            NotificationCenter.default.post(name: Notifications.NicknameUpdated, object: nil, userInfo: response)
        })
        setTask.errorTitle = "Nickname Error"
        setTask.sendRequest(request)
        
    }
    
    func updateContact(_ contact: Contact) {

        contactDatabase.update([contact])
        ContactManager.contactMap[contact.publicId] = contact
        for index in 0..<ContactManager.contactList.count {
            if ContactManager.contactList[index].publicId == contact.publicId {
                ContactManager.contactList[index] = contact
            }
        }

    }

    func updateContacts(_ serverContacts: [[AnyHashable: Any]]) -> [Contact] {

        var updates = [Contact]()

        for serverContact in serverContacts {
            let publicId = serverContact["publicId"] as? String ?? ""
            if let contact = ContactManager.contactMap[publicId] {
                contact.status = serverContact["status"] as! String
                contact.timestamp = (serverContact["timestamp"] as! NSNumber).int64Value
                let authData = serverContact["authData"] as! String
                contact.authData = Data(base64Encoded: authData)
                let nonce = serverContact["nonce"] as! String
                contact.nonce = Data(base64Encoded: nonce)
                let keys = serverContact["messageKeys"] as! [String]
                var messageKeys = [Data]()
                for key in keys {
                    messageKeys.append(Data(base64Encoded: key)!)
                }
                contact.messageKeys = messageKeys
                updates.append(contact)
            }
            else {
                var info = [AnyHashable: Any]()
                info["title"] = "Contact Error"
                info["message"] = "Updated contact not found"
                NotificationCenter.default.post(name: Notifications.PresentAlert, object: nil, userInfo: info)
            }
        }
        contactDatabase.update(updates)
        return updates

    }

    @objc func updatePendingContacts() {

        var pending = [String]()
        for contact in ContactManager.contactList {
            if contact.status == "pending" {
                pending.append(contact.publicId)
            }
        }

        var request = [AnyHashable: Any]()
        request["method"] = "UpdatePendingContacts"
        request["pending"] = pending
        let updateTask = EnclaveTask({ (response: [AnyHashable: Any]) -> Void in
            if let serverContacts = response["contacts"] as? [[AnyHashable: Any]] {
                if serverContacts.count > 0 {
                    let updated = self.updateContacts(serverContacts)
                    NotificationCenter.default.post(name: Notifications.PendingContactsUpdated, object: updated)
                    print("\(updated.count) contacts updated")
                }
            }
        })
        updateTask.errorTitle = "Contact Error"
        updateTask.sendRequest(request)
        
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
        if let info = notification.userInfo,
            let publicId = info["publicId"] as? String {
            deleteContact(publicId)
        }
        else {
            let alertColor = UIColor.flatSand
            RKDropdownAlert.title("Delete Contact Error", message: "That nickname doesn't exist",
                                  backgroundColor: alertColor,
                                  textColor: ContrastColorOf(alertColor, returnFlat: true),
                                  time: 2, delegate: nil)
        }

    }

}
