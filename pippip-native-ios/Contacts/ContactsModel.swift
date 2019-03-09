//
//  ContactsModel.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/27/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import Foundation
import RealmSwift
import CocoaLumberjack

class ContactsModel {
    
    static var contactsModel: ContactsModel?
    static var instance: ContactsModel {
        get {
            if let model = contactsModel {
                return model
            } else {
                contactsModel = ContactsModel()
                return contactsModel!
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
    var allContactIds: [Int] {
        return Array(contactIdMap.keys)
    }
    
    var allContacts: [Contact] {
        var all = [Contact]()
        all.append(contentsOf: acceptedContactSet)
        all.append(contentsOf: rejectedContactSet)
        all.append(contentsOf: ignoredContactSet)
        all.append(contentsOf: pendingContactSet)
        return all.sorted()
    }
    var sessionState = SessionState()
    var config = Configurator()

    private init() {
        loadContacts()
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
                    ContactManager().acknowledgeRequest(contactRequest: request, response: "accept")
                }
            }
        }
        
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
    
    func contactRequestExists(_ publicId: String) -> Bool {
        
        let request = ContactRequest(publicId: publicId, directoryId: nil)
        return requestSet.contains(request)
        
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
    
    func mapContacts() {
        
        contactMap.removeAll()
        for contact in allContacts {
            contactMap[contact.publicId] = contact
            contactIdMap[contact.contactId] = contact
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
    
    func setContactStatus(publicId: String, status: String) {
        
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
    
    func loadContacts() {
        
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

// Database and encoding functions
extension ContactsModel {
    
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


