//
//  AccountConfig.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/10/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import RealmSwift

class AccountConfig: Object {

    @objc dynamic var version: Float = Configurator.currentVersion
    @objc dynamic var nickname: String?
    @objc dynamic var contactPolicy: String = "public"
    @objc dynamic var currentMessageId: Int64 = 0
    @objc dynamic var currentContactId: Int = 0
    @objc dynamic var whitelist: Data?
    @objc dynamic var storeCleartextMessages: Bool = false
    @objc dynamic var useLocalAuth: Bool = true

}
