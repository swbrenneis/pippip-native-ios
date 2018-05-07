//
//  DatabaseMessage.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/5/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import RealmSwift

class DatabaseMessage: Object {

    @objc dynamic var version: Float = 1.0
    @objc dynamic var contactId: Int32 = -1
    @objc dynamic var messageId: Int64 = -1
    @objc dynamic var messageType: String = "user-text"
    @objc dynamic var message: Data?
    @objc dynamic var cleartext: String?
    @objc dynamic var keyIndex: Int32 = 0
    @objc dynamic var sequence: Int64 = 1;
    @objc dynamic var timestamp: Int64 = 0
    @objc dynamic var read: Bool = false
    @objc dynamic var acknowledged: Bool = false
    @objc dynamic var originating: Bool = false
    @objc dynamic var compressed: Bool = false

    override static func primaryKey() -> String {
        return "messageId"
    }
    
}
