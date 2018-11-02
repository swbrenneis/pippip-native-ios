//
//  ContactManager.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/10/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation
import RealmSwift
import CocoaLumberjack

struct ContactRequest: Hashable {

    var directoryId: String?
    var publicId: String
    var hashValue: Int {
        return publicId.hashValue
    }
    var displayId: String {
        if directoryId != nil {
            return directoryId!
        }
        else {
            return publicId
        }
    }

    init(publicId: String, directoryId: String?) {

        self.publicId = publicId
        self.directoryId = directoryId

    }

    init?(request: [String: String]) {

        guard let puid = request["publicId"] else { return nil }
        publicId = puid
        directoryId = request["directoryId"]

    }

    static func ==(lhs: ContactRequest, rhs: ContactRequest) -> Bool {
        return lhs.publicId == rhs.publicId
    }

}

class ContactManager: NSObject {

    static private var theInstance: ContactManager?
    static var instance: ContactManager {
        get {
            if let contactManager = ContactManager.theInstance {
                return contactManager
            }
            else {
                ContactManager.theInstance = ContactManager()
                return ContactManager.theInstance!
            }
        }
    }
    
    private var contactSet = Set<Contact>()
    private var contactMap = [String: Contact]()
    private var contactIdMap = [Int: Contact]()
    private var requestSet = Set<ContactRequest>()

    var sessionState = SessionState()
    var config = Configurator()
    var pendingRequests: [ContactRequest] {
        return Array(requestSet)
    }
    var contactList: [Contact] {
        return contactSet.sorted()
    }
    var visibleContactList: [Contact] {
        var visible = [Contact]()
        for contact in contactSet {
            if contact.status != "ignored" {
                visible.append(contact)
            }
        }
        return visible.sorted()
    }
 
    private override init() {

        super.init()
        
        //NotificationCenter.default.addObserver(self, selector: #selector(authComplete(_:)),
        //                                       name: Notifications.AuthComplete, object: nil)

    }
    
    func acknowledgeRequest(contactRequest: ContactRequest, response: String) {

        let request = AcknowledgeRequest(requestingId: contactRequest.publicId, response: response)
        let delegate = AcknowledgeRequestDelegate(request: request, contactRequest: contactRequest)
        let ackTask = EnclaveTask<AcknowledgeRequest, AcknowledgeRequestResponse>(delegate: delegate)
        ackTask.errorTitle = "Contact Error"
        ackTask.sendRequest(request)

    }

    func addContact(_ contact: Contact) {

        if contactMap[contact.publicId] != nil {
            print("Duplicate contact: \(contact.displayName)")
//            alertPresenter.errorAlert(title: "Contact Error", message: "Attempted to add duplicate contact")
        }
        else {
            contact.contactId = config.newContactId()
            contactMap[contact.publicId] = contact
            contactIdMap[contact.contactId] = contact
            contactSet.insert(contact)
        }

        do {
            let encoded = try encodeContact(contact)
            let dbContact = DatabaseContact()
            dbContact.version = contact.version
            dbContact.contactId = contact.contactId
            dbContact.encoded = encoded
            let realm = try Realm()
            try realm.write {
                realm.add(dbContact)
            }
        }
        catch {
            print("Error adding contact: \(error)")
        }

    }
    
    func addWhitelistEntry(publicId: String, directoryId: String?) throws {

        if let _ = config.whitelistIndexOf(publicId: publicId) {
            throw ContactError(error: "Whitelist entry exists")
        }
        let request = UpdateWhitelistRequest(id: publicId, action: "add")
        let delegate = UpdateWhitelistDelegate(request: request, updateType: .addEntry)
        delegate.publicId = publicId
        delegate.directoryId = directoryId
        let addTask = EnclaveTask<UpdateWhitelistRequest, UpdateWhitelistResponse>(delegate: delegate)
        addTask.errorTitle = "Permitted Contact List Error"
        addTask.sendRequest(request)
        
    }

    func addRequests(_ requests: [[String: String]]) {

        var newRequests = [ContactRequest]()
        for request in requests {
            if let contactRequest = ContactRequest(request: request) {
                let result = requestSet.insert(contactRequest)
                if result.inserted {
                    newRequests.append(contactRequest)
                }
            }
        }

    }

    func allContactIds() -> [Int] {

        var allIds = [Int]()
        for contact in contactSet {
            allIds.append(contact.contactId)
        }
        return allIds

    }

    func clearContacts() {

        contactSet.removeAll()
        contactMap.removeAll()
        contactIdMap.removeAll()

    }

    func clearRequests() {

        requestSet.removeAll()

    }

    func deleteContact(publicId: String) {
        
        let request = DeleteContactRequest(publicId: publicId)
        let delegate = DeleteContactDelegate(request: request)
        let deleteTask = EnclaveTask<DeleteContactRequest, DeleteContactResponse>(delegate: delegate)
        deleteTask.errorTitle = "Contact Error"
        deleteTask.sendRequest(request)
        
    }

    func deleteContact(contact: Contact) {

        contactMap.removeValue(forKey: contact.publicId)
        contactSet.remove(contact)

        let realm = try! Realm()
        if let dbContact = realm.objects(DatabaseContact.self).filter("contactId = %ld", contact.contactId).first {
            try! realm.write {
                realm.delete(dbContact)
            }
        }
        
    }
    
    func deleteContactRequest(_ contactRequest: ContactRequest) {
        
        requestSet.remove(contactRequest)
    
    }

    func deleteWhitelistEntry(publicId: String) {

        let request = UpdateWhitelistRequest(id: publicId, action: "delete")
        let delegate = UpdateWhitelistDelegate(request: request, updateType: .deleteEntry)
        delegate.publicId = publicId
        let addTask = EnclaveTask<UpdateWhitelistRequest, UpdateWhitelistResponse>(delegate: delegate)
        addTask.errorTitle = "Permitted Contact List Error"
        addTask.sendRequest(request)

    }
    
    func getContact(publicId: String) -> Contact? {

        return contactMap[publicId]

    }

    func getContact(contactId: Int) -> Contact? {

        return contactIdMap[contactId]

    }

    func getContactId(_ publicId: String) -> Int {

        if let contact = contactMap[publicId] {
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
    
    func getRequestStatus(/* retry: Bool, publicId: String? */) {
        
        var pending = [String]()
        for contact in contactSet {
            if contact.status == "pending" {
                pending.append(contact.publicId)
            }
        }
        
        let request = GetRequestStatusRequest(requestedIds: pending)
        let delegate = GetRequestStatusDelegate(request: request /*, publicId: publicId, retry: retry */)
        let updateTask = EnclaveTask<GetRequestStatusRequest, GetRequestStatusResponse>(delegate: delegate)
        updateTask.errorTitle = "Contact Error"
        updateTask.sendRequest(request)
        
    }

    func mapContacts() {
        
        contactMap.removeAll()
        for contact in contactSet {
            contactMap[contact.publicId] = contact
            contactIdMap[contact.contactId] = contact
        }
        
    }
    
    func matchDirectoryId(directoryId: String?, publicId: String?) {

        let request = MatchDirectoryIdRequest(publicId: publicId, directoryId: directoryId)
        let delegate = MatchDirectoryIdDelegate(request: request)
        let matchTask = EnclaveTask<MatchDirectoryIdRequest, MatchDirectoryIdResponse>(delegate: delegate)
        matchTask.errorTitle = "Directory ID Error"
        matchTask.sendRequest(request)
        
    }

    @discardableResult
    func requestContact(publicId: String, directoryId: String?, retry: Bool) -> Bool {

        if contactMap[publicId] == nil || retry {
            let request = RequestContactRequest(requestedId: publicId, retry: retry)
            let delegate = RequestContactDelegate(request: request, retry: retry, directoryId: directoryId)
            let reqTask = EnclaveTask<RequestContactRequest, RequestContactResponse>(delegate: delegate)
            reqTask.errorTitle = "Contact Error"
            reqTask.sendRequest(request)
            return true
        }
        else {
            return false
        }
        
    }

    func searchContacts(_ fragment:String) -> [Contact] {

        var result = [Contact]()
        for contact in contactSet {
            let pCompare = contact.publicId.uppercased()
            if (pCompare.contains(fragment)) {
                result.append(contact)
            }
            else if let directoryId = contact.directoryId {
                let nCompare = directoryId.uppercased()
                if (nCompare.contains(fragment)) {
                    result.append(contact)
                }
            }
        }
        return result

    }

    func setContactPolicy(_ policy: String) {
        
        let request = SetContactPolicyRequest(policy: policy)
        let delegate = SetContactPolicyDelegate(request: request)
        let setTask = EnclaveTask<SetContactPolicyRequest, SetContactPolicyResponse>(delegate: delegate)
        setTask.errorTitle = "Policy Error"
        setTask.sendRequest(request)
        
    }

    func setDirectoryId(contactId: Int, directoryId: String?) {

        guard let contact = contactIdMap[contactId] else { return }
        contact.directoryId = directoryId
        let realm = try! Realm()
        if let dbContact = realm.objects(DatabaseContact.self).filter("contactId = %ld", contact.contactId).first {
            try! realm.write {
                dbContact.encoded = try encodeContact(contact)
            }
            AsyncNotifier.notify(name: Notifications.DirectoryIdSet, object: contact)
        }
        else {
            DDLogError("Contact \(contact.displayName) not found in database")
        }
        
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

    func updateContact(_ update: Contact) throws {

        contactMap[update.publicId] = update
        contactSet.update(with: update)
        try updateContacts([update])

    }

    func updateContacts(_ serverContacts: [ServerContact]) throws -> [Contact] {

        var updates = [Contact]()

        for serverContact in serverContacts {
            if let contact = contactMap[serverContact.publicId!] {
                contact.status = serverContact.status!
                contact.timestamp = Int64(serverContact.timestamp!)
                if contact.status == "accepted" {
                    contact.authData = Data(base64Encoded: serverContact.authData!)
                    contact.nonce = Data(base64Encoded: serverContact.nonce!)
                    var messageKeys = [Data]()
                    for key in serverContact.messageKeys! {
                        messageKeys.append(Data(base64Encoded: key)!)
                    }
                    contact.messageKeys = messageKeys
                }
                updates.append(contact)
            }
            else {
                print("Updated contact not found")
                // alertPresenter.errorAlert(title: "Contact Error", message: "Updated contact not found")
            }
        }
        try updateContacts(updates)
        return updates

    }

    func updateDirectoryId(newDirectoryId: String?, oldDirectoryId: String?) {

        let request = SetDirectoryIdRequest(oldDirectoryId: oldDirectoryId ?? "", newDirectoryId: newDirectoryId ?? "")
        let delegate = SetDirectoryIdDelegate(request: request)
        let setTask = EnclaveTask<SetDirectoryIdRequest, SetDirectoryIdResponse>(delegate: delegate)
        setTask.errorTitle = "Directory ID Error"
        setTask.sendRequest(request)
        
    }

    // Notifications
    /*
    @objc func authComplete(_ notification: Notification) {

        if (config.authenticated) {
            contactSet.removeAll()
            let realm = try! Realm()
            let dbContacts = realm.objects(DatabaseContact.self)
            for dbContact in dbContacts {
                do {
                    let contact = try decodeContact(dbContact.encoded!)
                    contact.contactId = dbContact.contactId
                    contact.version = dbContact.version
                    contactSet.insert(contact)
                }
                catch {
                    print("Error decoding contact: \(error)")
                }
            }
            mapContacts()
        }
        
    }
*/
}

// Database and encoding functions
extension ContactManager {
/*
    func addContactRequests(_ requests: [ContactRequest]) {

        let realm = try! Realm()
        for request in requests {
            let dbRequest = DatabaseContactRequest()
            dbRequest.publicId = request.publicId
            dbRequest.directoryId = request.directoryId
            try! realm.write {
                realm.add(dbRequest)
            }
        }

    }
*/
    func decodeContact(_ encoded: Data) throws -> Contact {

        let codec = CKGCMCodec(data: encoded)
        try codec.decrypt(sessionState.contactsKey!, withAuthData: sessionState.authData!)
        let contact = Contact()
        contact.publicId = codec.getString()
        contact.status = codec.getString()
        let directoryId = codec.getString()
        if directoryId.utf8.count > 0 {
            contact.directoryId = directoryId
        }
        contact.timestamp = codec.getLong()
        let count = codec.getLong()
        if count > 0 {
            contact.messageKeys = [Data]()
            while contact.messageKeys!.count < count {
                contact.messageKeys!.append(codec.getBlock())
            }
            contact.authData = codec.getBlock()
            contact.nonce = codec.getBlock()
            contact.currentIndex = Int(codec.getLong())
            contact.currentSequence = codec.getLong()
        }

        return contact
    
    }

    func encodeContact(_ contact: Contact) throws -> Data {

        let codec = CKGCMCodec()
        codec.put(contact.publicId)
        codec.put(contact.status)
        codec.put(contact.directoryId ?? "")
        codec.putLong(contact.timestamp)
        if contact.messageKeys != nil {
            codec.putLong(Int64(contact.messageKeys!.count))
            for key in contact.messageKeys! {
                codec.putBlock(key)
            }
            codec.putBlock(contact.authData!)
            codec.putBlock(contact.nonce!)
            codec.putLong(Int64(contact.currentIndex))
            codec.putLong(contact.currentSequence)
        }
        else {
            codec.putLong(0)
        }

        let encoded = codec.encrypt(sessionState.contactsKey!, withAuthData: sessionState.authData!)
        if encoded == nil {
            throw CryptoError(error: codec.lastError!)
        }
        return encoded!

    }

    func updateContacts(_ contacts: [Contact]) throws {
        
        let realm = try! Realm()
        for contact in contacts {
            if let dbContact = realm.objects(DatabaseContact.self).filter("contactId = %ld", contact.contactId).first {
                try! realm.write {
                    dbContact.encoded = try encodeContact(contact)
                }
            }
            else {
                print("Contact \(contact.displayName) not found in database")
            }
        }

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
