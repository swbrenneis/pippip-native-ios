//
//  AccountConfig.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/5/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import RealmSwift

class AccountConfig: Object {

    @objc dynamic var version: Float = 1.2
    @objc dynamic var accountName: String = ""
    @objc dynamic var nickname: String? = nil
    @objc dynamic var contactPolicy: String = "whitelist"
    @objc dynamic var currentContactId: Int32 = 1
    @objc dynamic var currentMessageId: Int64 = 1
    @objc dynamic var whitelist: Data? = nil
    @objc dynamic var cleartextMessages: Bool = false
    @objc dynamic var localAuth: Bool = true

    override static func primaryKey() -> String {
        return "accountName"
    }

}
