//
//  ContactManager.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/10/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ContactManager: NSObject {

    static private var contactList = [Contact]()
    static private var contactMap = [String: Contact]()
    static private var initialized = false

    var contactDatabase: ContactDatabase
    var config = Configurator()
 
    override init() {

        contactDatabase = ContactDatabase()

        super.init()

        if (!ContactManager.initialized) {
            ContactManager.initialized = true
            ContactManager.contactList = contactDatabase.getContactList()
            mapContacts()
        }
        
    }

    func addContact(_ contact: Contact) {

        contactDatabase.add(contact)
        ContactManager.contactMap[contact.publicId] = contact
        ContactManager.contactList.append(contact)

    }

    func acknowledgeRequest(response: String, publicId: String, nickname: String?) {

        var request = [AnyHashable: Any]()
        request["method"] = "AcknowledgeRequest"
        request["id"] = publicId
        request["response"] = response
        let ackTask = EnclaveTask({ (response: [AnyHashable: Any]) -> Void in
            if let serverContact = response["acknowledged"] as? [AnyHashable: Any] {
                if let contact = Contact(serverContact: serverContact) {
                    contact.nickname = nickname
                    self.addContact(contact)
                }
            }
            else {
                var info = [AnyHashable: Any]()
                info["title"] = "Contact Error"
                info["title"] = "Invalid response to acknowledgement"
                NotificationCenter.default.post(name: Notifications.PresentAlert, object: nil, userInfo: info)
            }
            if let pending = response["pending"] as? [[AnyHashable: Any]] {
                NotificationCenter.default.post(name: Notifications.RequestAcknowledged,
                                                object: pending, userInfo: nil)
            }
            else {
                let pending = [[AnyHashable: Any]]()
                NotificationCenter.default.post(name: Notifications.RequestAcknowledged,
                                                object: pending, userInfo: nil)
            }
        })
        ackTask.errorTitle = "Contact Error"
        ackTask.sendRequest(request)

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

    func deleteContact(_ publicId: String) {
        
        var request = [AnyHashable: Any]()
        request["method"] = "DeleteContact"
        request["publicId"] = publicId
        let deleteTask = EnclaveTask({ (response: [AnyHashable: Any]) -> Void in
            if let publicId = response["publicId"] as? String {
                self.contactDatabase.deleteContact(publicId)
                let contactId = self.config.getContactId(publicId)
                self.config.deleteContactId(publicId)
                ContactManager.contactMap.removeValue(forKey: publicId)
                let messageDatabase = MessagesDatabase()
                messageDatabase.deleteAllMessages(contactId)
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

        for contact in ContactManager.contactList {
            if contact.contactId == contactId {
                return contact
            }
        }
        return nil

    }

    func getContactList() -> [Contact] {
        return ContactManager.contactList
    }

    @objc func getPendingRequests() {

        var request = [AnyHashable: Any]()
        request["method"] = "GetPendingRequests"
        let getTask = EnclaveTask({ (response: [AnyHashable: Any]) -> Void in
            if let requests = response["requests"] as? [[AnyHashable: Any]] {
                NotificationCenter.default.post(name: Notifications.RequestsUpdated, object: requests)
                print("\(requests.count) pending requests returned")
            }
            else {
                var info = [AnyHashable: Any]()
                info["title"] = "Contact Error"
                info["title"] = "Invalid response to get requests"
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

    func searchContacts(_ fragment:String) -> [Contact] {

        var result = [Contact]()
        for contact in ContactManager.contactList {
            if (contact.publicId.contains(fragment)) {
                result.append(contact)
            }
            else if let nickname = contact.nickname {
                if (nickname.contains(fragment)) {
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
            if let updated = Contact(serverContact: serverContact) {
                let contact = ContactManager.contactMap[updated.publicId]
                updated.nickname = contact?.nickname
                ContactManager.contactMap[updated.publicId] = updated
                for index in 0..<ContactManager.contactList.count {
                    if ContactManager.contactList[index].publicId == updated.publicId {
                        ContactManager.contactList[index] = updated
                    }
                }
                updates.append(updated)
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
