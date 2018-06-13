//
//  DatabaseMessage.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/11/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import RealmSwift

class DatabaseMessage: Object {

    @objc dynamic var version: Float = Message.currentVersion
    @objc dynamic var contactId: Int = 0
    @objc dynamic var messageId: Int64 = 0
    @objc dynamic var messageType: String = "user"
    @objc dynamic var ciphertext: Data?
    @objc dynamic var cleartext: String?
    @objc dynamic var keyIndex: Int = 0
    @objc dynamic var sequence: Int64 = 0
    @objc dynamic var timestamp: Int64 = 0
    @objc dynamic var read: Bool = false
    @objc dynamic var acknowledged: Bool = false
    @objc dynamic var originating: Bool = false
    @objc dynamic var compressed: Bool = false
    @objc dynamic var failed: Bool = false

    override static func primaryKey() -> String? {
        return "messageId"
    }

}
