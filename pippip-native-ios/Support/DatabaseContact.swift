//
//  DatabaseContact.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/6/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import RealmSwift

class DatabaseContact: Object {

    @objc dynamic var version: Float = 1.0
    @objc dynamic var contactId: Int32 = 0
    @objc dynamic var encoded: Data!

    override static func primaryKey() -> String {
        return "contactId"
    }
    
}
