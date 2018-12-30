//
//  ContactModel.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/26/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation
import RealmSwift
import CocoaLumberjack

struct ContactRequest: Hashable {
    
    var directoryId: String?
    var publicId: String?
    var hashValue: Int {
        return publicId.hashValue
    }
    var displayId: String {
        if directoryId != nil {
            return directoryId!
        }
        else {
            return publicId!
        }
    }
    
    init(publicId: String?, directoryId: String?) {
        
        self.publicId = publicId
        self.directoryId = directoryId
        
    }
    
    init?(request: [String: String]) {
        
        // Public ID must be present in a request returned from the server
        if let puid = request["publicId"] {
            publicId = puid
        }
        else {
            return nil
        }
        directoryId = request["directoryId"]
        
    }
    
    static func ==(lhs: ContactRequest, rhs: ContactRequest) -> Bool {
        return lhs.directoryId == rhs.directoryId && lhs.publicId == rhs.publicId
    }
    
}

enum ContactAction {
    case added, deleted, acknowledged, requestsAdded, requestDeleted
}

enum ObservedContactAction {
    case added(Contact)
    case deleted(Contact)
    case acknowledged(Contact)
    case requestsAdded
    case requestsDeleted
}

class ContactsModel: NSObject, ObservableProtocol {

    private static var theInstance: ContactsModel?
    
    static var instance: ContactsModel {
        if let modelInstance = ContactsModel.theInstance {
            return modelInstance
        }
        else {
            let modelInstance = ContactsModel()
            ContactsModel.theInstance = modelInstance
            return modelInstance
        }
    }
    
    var observers = [ContactAction: [ObserverProtocol]]()
    var config = Configurator()
    var alertPresenter = AlertPresenter()

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

    func addObserver(action: ContactAction, observer: ObserverProtocol) {
        
        if var observerList = observers[action] {
            observerList.append(observer)
        }
        else {
            var newList = [ObserverProtocol]()
            newList.append(observer)
            observers[action] = newList
        }
        
    }
    
    func addContact(contact: Contact) throws /* -> Contact */ {
        
        contact.contactId = config.newContactId()
        let encoded = try encodeContact(contact)
        let dbContact = DatabaseContact()
        dbContact.version = contact.version
        dbContact.contactId = contact.contactId
        dbContact.encoded = encoded
        let realm = try Realm()
        try realm.write {
            realm.add(dbContact)
        }
        
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
            throw ContactError.invalidStatus
        }

        if let observerList = observers[.added] {
            for observer in observerList {
                observer.update(observable: self, object: ObservedContactAction.added(contact))
            }
        }

    }
    
    func addPendingContact(_ contact: Contact) throws {
        
        // We can only check for duplicate public ID or duplicate contact ID
        // Duplicate directory IDs are allowed
        if let publicId = contact.publicId {
            if contactMap[publicId] != nil {
                throw ContactError.duplicateContact
            }
        }
        
        if let _ = contactIdMap[contact.contactId] {
            throw ContactError.duplicateContact
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
        
        contact.contactId = config.newContactId()
        if let publicId = contact.publicId {
            contactMap[publicId] = contact
        }
        contactIdMap[contact.contactId] = contact
        pendingContactSet.insert(contact)
        
        if let observerList = observers[.added] {
            for observer in observerList {
                observer.update(observable: self, object: ObservedContactAction.added(contact))
            }
        }
        
    }
    
    func addRequests(requests: [ContactRequest]) {
        
        for contactRequest in requests {
                let result = requestSet.insert(contactRequest)
                if !result.inserted {
                    DDLogWarn("Duplicate request for public ID \(contactRequest.publicId)")
                }
        }

        if let observerList = observers[.requestsAdded] {
            for observer in observerList {
                observer.update(observable: self, object: ObservedContactAction.requestsAdded)
            }
        }
        
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

        if let observerList = observers[.requestDeleted] {
            for observer in observerList {
                observer.update(observable: self, object: ObservedContactAction.requestsDeleted)
            }
        }
        

    }
    
    func contactAcknowledged(contact: Contact) throws {

        let realm = try Realm()
        if let dbContact = realm.objects(DatabaseContact.self).filter("contactId = %ld", contact.contactId).first {
            try realm.write {
                dbContact.encoded = try encodeContact(contact)
            }
            guard let publicId = contact.publicId else { throw ContactError.invalidPublicId }
            contactMap[publicId] = contact
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
            
            if let observerList = observers[.acknowledged] {
                for observer in observerList {
                    observer.update(observable: self, object: ObservedContactAction.acknowledged(contact))
                }
            }
        }
        else {
            DDLogError("Contact \(contact.displayName) not found in database")
            alertPresenter.errorAlert(title: "Contact Request Error", message: Strings.errorInternal)
        }
        
    }
    
    func contactRequestExists(publicId: String?, directoryId: String?) -> Bool {
        
        let request = ContactRequest(publicId: publicId, directoryId: directoryId)
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
                throw ContactError.notFound
            }
        }
        try updateDatabaseContacts(updates)
        return updates
        
    }
    
    func decodeContact(_ encoded: Data) throws -> Contact {

        let sessionState = SessionState.instance
        let codec = CKGCMCodec(data: encoded)
        try codec.decrypt(sessionState.contactsKey!, withAuthData: sessionState.authData!)
        let contact = Contact()
        let publicId = codec.getString()
        if publicId.utf8.count > 0 {
            contact.publicId = publicId
        }
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
    
    func deleteContact(contact: Contact) throws {
        
        guard let publicId = contact.publicId else { throw ContactError.invalidPublicId }
        contactMap.removeValue(forKey: publicId)
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
        
        if let observerList = observers[.requestDeleted] {
            for observer in observerList {
                observer.update(observable: self, object: ContactAction.added)
            }
        }

    }
    
    func encodeContact(_ contact: Contact) throws -> Data {
        
        let codec = CKGCMCodec()
        codec.put(contact.publicId ?? "")
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
        
        let sessionState = SessionState.instance
        let encoded = codec.encrypt(sessionState.contactsKey!, withAuthData: sessionState.authData!)
        if encoded == nil {
            throw CryptoError(error: codec.lastError!)
        }
        return encoded!
        
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
            if let publicId = contact.publicId {
                contactMap[publicId] = contact
            }
            contactIdMap[contact.contactId] = contact
        }
        
    }
    
    // Swift protocols leave a lot to be desired.
    func removeObserver(action: ContactAction, observer: ObserverProtocol) {

        if var observerList = observers[action] {
            var indexOf = NSNotFound
            for (index, element) in observerList.enumerated() {
                if element.isEqual(observer) {
                    indexOf = index
                }
            }
            if indexOf != NSNotFound {
                observerList.remove(at: indexOf)
            }
        }

    }
    
    func searchAcceptedContacts(fragment: String) -> [Contact] {
        
        var result = [Contact]()
        for contact in acceptedContactSet {
            if let publicId = contact.publicId {
                let pCompare = publicId.uppercased()
                if (pCompare.contains(fragment)) {
                    result.append(contact)
                }
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
            if let publicId = contact.publicId {
                let pCompare = publicId.uppercased()
                if (pCompare.contains(fragment)) {
                    result.append(contact)
                }
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
            if let publicId = contact.publicId {
                let pCompare = publicId.uppercased()
                if (pCompare.contains(fragment)) {
                    result.append(contact)
                }
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
    
    func updateKeyInfo(contactId: Int, currentIndex: Int, currentSequence: Int64) throws {
        
        guard let contact = contactIdMap[contactId] else { throw ContactError.notFound }
        contact.currentIndex = currentIndex
        contact.currentSequence = currentSequence
        try updateDatabaseContacts([contact])
        
    }
    
    func updateTimestamp(contactId: Int, timestamp: Int64) throws {
        
        guard let contact = contactIdMap[contactId] else { throw ContactError.notFound }
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
    
}
