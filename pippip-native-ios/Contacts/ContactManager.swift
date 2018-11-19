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
    
    private var acceptedContactSet = Set<Contact>()
    private var rejectedContactSet = Set<Contact>()
    private var ignoredContactSet = Set<Contact>()
    private var pendingContactSet = Set<Contact>()
    private var contactMap = [String: Contact]()
    private var contactIdMap = [Int: Contact]()
    private var requestSet = Set<ContactRequest>()

    var sessionState = SessionState()
    var config = Configurator()
    var pendingRequests: [ContactRequest] {
        return Array(requestSet)
    }
    var acceptedContactList: [Contact] {
        return acceptedContactSet.sorted()
    }
    var rejectedContactList: [Contact] {
        return rejectedContactSet.sorted()
    }
    var ignoredContactList: [Contact] {
        return ignoredContactSet.sorted()
    }
    var pendingContactList: [Contact] {
        return pendingContactSet.sorted()
    }
    var allContacts: [Contact] {
        var all = [Contact]()
        all.append(contentsOf: acceptedContactSet)
        all.append(contentsOf: rejectedContactSet)
        all.append(contentsOf: ignoredContactSet)
        all.append(contentsOf: pendingContactSet)
        return all.sorted()
    }
 
    private override init() {

        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(authComplete(_:)),
                                               name: Notifications.AuthComplete, object: nil)

    }
    
    func acknowledgeRequest(contactRequest: ContactRequest, response: String) {

        let request = AcknowledgeRequest(requestingId: contactRequest.publicId, response: response)
        let delegate = AcknowledgeRequestDelegate(request: request, contactRequest: contactRequest)
        let ackTask = EnclaveTask<AcknowledgeRequest, AcknowledgeRequestResponse>(delegate: delegate)
        ackTask.errorTitle = "Contact Error"
        ackTask.sendRequest(request)

    }

    func addContact(serverContact: ServerContact) throws -> Contact {

        let contact = Contact(serverContact: serverContact)
        contact.contactId = config.newContactId()
        switch contact.status {
        case "accepted":
            acceptedContactSet.insert(contact)
            break
        case "rejected":
            rejectedContactSet.insert(contact)
            break
        case "ignored":
            ignoredContactSet.insert(contact)
            break
        case "pending":
            pendingContactSet.insert(contact)
            break
        default:
            DDLogError("Invalid contact status: \(contact.status)")
            throw ContactError(error: "Invalid contact status")
        }

        let encoded = try encodeContact(contact)
        let dbContact = DatabaseContact()
        dbContact.version = contact.version
        dbContact.contactId = contact.contactId
        dbContact.encoded = encoded
        let realm = try Realm()
        try realm.write {
            realm.add(dbContact)
        }
        
        return contact

    }
    
    func addPendingContact(_ contact: Contact) {

        if contactMap[contact.publicId] != nil {
            DDLogError("Duplicate contact: \(contact.displayName)")
        }
        else {
            contact.contactId = config.newContactId()
            contactMap[contact.publicId] = contact
            contactIdMap[contact.contactId] = contact
            pendingContactSet.insert(contact)

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
                DDLogError("Error adding contact: \(error)")
            }
        }

    }
    
    func addRequests(requests: [[String: String]]) {

        var toAck = [ContactRequest]()
        for pair in requests {
            guard let contactRequest = ContactRequest(request: pair) else { continue }
            if config.contactPolicy == "whitelist" && config.autoAccept && whitelistIdExists(publicId: contactRequest.publicId) {
                toAck.append(contactRequest)
            }
            else {
                let result = requestSet.insert(contactRequest)
                if !result.inserted {
                    DDLogWarn("Duplicate request for public ID \(contactRequest.publicId)")
                }
            }
        }
        
        if !toAck.isEmpty {
            DispatchQueue.global().async {
                for request in toAck {
                    self.acknowledgeRequest(contactRequest: request, response: "accept")
                }
            }
        }

    }

    func addWhitelistEntry(publicId: String, directoryId: String?) throws {

        if whitelistIdExists(publicId: publicId) {
            throw ContactError(error: "Whitelist ID \(publicId) exists")
        }
        let request = UpdateWhitelistRequest(id: publicId, action: "add")
        let delegate = UpdateWhitelistDelegate(request: request, updateType: .addEntry)
        delegate.publicId = publicId
        delegate.directoryId = directoryId
        let addTask = EnclaveTask<UpdateWhitelistRequest, UpdateWhitelistResponse>(delegate: delegate)
        addTask.errorTitle = "Permitted Contact List Error"
        addTask.sendRequest(request)
        
    }
    
    func allContactIds() -> [Int] {

        return Array(contactIdMap.keys)

    }

    func clearContacts() {

        acceptedContactSet.removeAll()
        rejectedContactSet.removeAll()
        pendingContactSet.removeAll()
        ignoredContactSet.removeAll()
        contactMap.removeAll()
        contactIdMap.removeAll()

    }

    func clearRequests() {

        requestSet.removeAll()

    }

    func contactAcknowledged(contact: Contact) {

        contactMap[contact.publicId] = contact
        contactIdMap[contact.contactId] = contact
        switch contact.status {
        case "accepted":
            acceptedContactSet.insert(contact)
            break
        case "rejected":
            rejectedContactSet.insert(contact)
            break
        case "ignored":
            ignoredContactSet.insert(contact)
            break
        case "pending":
            pendingContactSet.insert(contact)
            break
        default:
            DDLogError("Invalid contact status: \(contact.status)")
        }

        let realm = try! Realm()
        if let dbContact = realm.objects(DatabaseContact.self).filter("contactId = %ld", contact.contactId).first {
            try! realm.write {
                dbContact.encoded = try encodeContact(contact)
            }
            //AsyncNotifier.notify(name: Notifications.DirectoryIdSet, object: contact)
        }
        else {
            DDLogError("Contact \(contact.displayName) not found in database")
        }

    }
    
    // Moves contacts from pending to the appropriate set
    func contactsAcknowledged(serverContacts: [ServerContact]) throws -> [Contact] {
        
        var updates = [Contact]()
        
        for serverContact in serverContacts {
            if let contact = contactMap[serverContact.publicId!] {
                pendingContactSet.remove(contact)
                contact.status = serverContact.status!
                contact.timestamp = Int64(serverContact.timestamp!)
                switch contact.status {
                case "accepted":
                    acceptedContactSet.insert(contact)
                    contact.authData = Data(base64Encoded: serverContact.authData!)
                    contact.nonce = Data(base64Encoded: serverContact.nonce!)
                    var messageKeys = [Data]()
                    for key in serverContact.messageKeys! {
                        messageKeys.append(Data(base64Encoded: key)!)
                    }
                    contact.messageKeys = messageKeys
                    break
                case "ignored":
                    ignoredContactSet.insert(contact)
                    break
                case "rejected":
                    rejectedContactSet.insert(contact)
                    break
                default:
                    DDLogError("Invalid contact status: \(contact.status)")
                }
                updates.append(contact)
            }
            else {
                throw ContactError(error: "Contact not found")
            }
        }
        try updateDatabaseContacts(updates)
        return updates
        
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
        contactIdMap.removeValue(forKey: contact.contactId)
        switch contact.status {
        case "accepted":
            acceptedContactSet.remove(contact)
            break
        case "rejected":
            rejectedContactSet.remove(contact)
            break
        case "pending":
            pendingContactSet.remove(contact)
            break
        case "ignored":
            ignoredContactSet.remove(contact)
            break
        default:
            DDLogError("Invalid contact status \(contact.status)")
        }

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

    func getContactId(publicId: String) -> Int? {

        if let contact = contactMap[publicId] {
            return contact.contactId
        }
        else {
            return nil
        }

    }

    func getPendingRequests() {
        
        let request = GetPendingRequests()
        let delegate = GetPendingRequestsDelegate(request: request)
        let getTask = EnclaveTask<GetPendingRequests, GetPendingRequestsResponse>(delegate: delegate)
        getTask.errorTitle = "Contact Error"
        getTask.sendRequest(request)
        
    }
    
    func getPublicId(directoryId: String) -> String? {

        let contacts = allContacts
        if let index = contacts.firstIndex(where: { contact in
            return contact.directoryId == directoryId
        }) {
            return contacts[index].publicId
        }
        else {
            return nil
        }
        
    }
    
    func getRequestStatus(/* retry: Bool, publicId: String? */) {
        
        var pending = [String]()
        for contact in pendingContactSet {
            pending.append(contact.publicId)
        }
        
        let request = GetRequestStatusRequest(requestedIds: pending)
        let delegate = GetRequestStatusDelegate(request: request /*, publicId: publicId, retry: retry */)
        let updateTask = EnclaveTask<GetRequestStatusRequest, GetRequestStatusResponse>(delegate: delegate)
        updateTask.errorTitle = "Contact Error"
        updateTask.sendRequest(request)
        
    }

    func mapContacts() {
        
        contactMap.removeAll()
        for contact in allContacts {
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

    func requestContact(publicId: String, directoryId: String?, retry: Bool) throws {

        if contactMap[publicId] == nil || retry {
            let request = RequestContactRequest(requestedId: publicId, retry: retry)
            let delegate = RequestContactDelegate(request: request, retry: retry, directoryId: directoryId)
            let reqTask = EnclaveTask<RequestContactRequest, RequestContactResponse>(delegate: delegate)
            reqTask.errorTitle = "Contact Error"
            reqTask.sendRequest(request)
        }
        else {
            throw ContactError(error: "Duplicate contact")
        }
        
    }

    func searchAcceptedContacts(fragment: String) -> [Contact] {
        
        var result = [Contact]()
        for contact in acceptedContactSet {
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
    
    func searchAllContacts(fragment: String) -> [Contact] {
        
        var result = [Contact]()
        for contact in allContacts {
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
    
    func searchPendingContacts(fragment: String) -> [Contact] {
        
        var result = [Contact]()
        for contact in pendingContactSet {
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

    func updateDirectoryId(newDirectoryId: String?, oldDirectoryId: String?) {

        let request = SetDirectoryIdRequest(oldDirectoryId: oldDirectoryId ?? "", newDirectoryId: newDirectoryId ?? "")
        let delegate = SetDirectoryIdDelegate(request: request)
        let setTask = EnclaveTask<SetDirectoryIdRequest, SetDirectoryIdResponse>(delegate: delegate)
        setTask.errorTitle = "Directory ID Error"
        setTask.sendRequest(request)
        
    }

    func updateKeyInfo(contactId: Int, currentIndex: Int, currentSequence: Int64) throws {

        guard let contact = contactIdMap[contactId] else { throw ContactError(error: "Contact does not exist") }
        contact.currentIndex = currentIndex
        contact.currentSequence = currentSequence
        try updateDatabaseContacts([contact])

    }
    
    func updateTimestamp(contactId: Int, timestamp: Int64) throws {

        guard let contact = contactIdMap[contactId] else { throw ContactError(error: "Contact does not exist") }
        contact.timestamp = timestamp
        try updateDatabaseContacts([contact])
        
    }

    func whitelistIdExists(publicId: String) -> Bool {

        if let _ = config.whitelistIndexOf(publicId: publicId) {
            return true
        }
        else {
            return false
        }

    }
    
    // Notifications

    @objc func authComplete(_ notification: Notification) {

        guard let success = notification.object as? Bool else { return }
        if success {
            acceptedContactSet.removeAll()
            rejectedContactSet.removeAll()
            ignoredContactSet.removeAll()
            pendingContactSet.removeAll()
            let realm = try! Realm()
            let dbContacts = realm.objects(DatabaseContact.self)
            for dbContact in dbContacts {
                do {
                    let contact = try decodeContact(dbContact.encoded!)
                    contact.contactId = dbContact.contactId
                    contact.version = dbContact.version
                    switch contact.status {
                    case "accepted":
                        acceptedContactSet.insert(contact)
                        break
                    case "rejected":
                        rejectedContactSet.insert(contact)
                        break
                    case "ignored":
                        ignoredContactSet.insert(contact)
                        break
                    case "pending":
                        pendingContactSet.insert(contact)
                        break
                    default:
                        DDLogError("Invalid contact status: \(contact.status)")
                    }
                }
                catch {
                    DDLogError("Error decoding contact: \(error)")
                }
            }
            mapContacts()
        }
        
    }

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

    private func updateDatabaseContacts(_ contacts: [Contact]) throws {
        
        let realm = try Realm()
        for contact in contacts {
            if let dbContact = realm.objects(DatabaseContact.self).filter("contactId = %ld", contact.contactId).first {
                try realm.write {
                    dbContact.encoded = try encodeContact(contact)
                }
            }
            else {
                DDLogError("Contact \(contact.displayName) not found in database")
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
