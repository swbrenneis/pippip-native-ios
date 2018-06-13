//
//  DatabaseContact.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/10/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import RealmSwift

class DatabaseContact: Object {

    @objc dynamic var version: Float = Contact.currentVersion
    @objc dynamic var contactId: Int = 0
    @objc dynamic var encoded: Data?

    override static func primaryKey() -> String? {
        return "contactId"
    }
    
}
