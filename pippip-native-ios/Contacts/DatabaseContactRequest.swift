//
//  DatabaseContactRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/11/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import RealmSwift

class DatabaseContactRequest: Object {

    @objc dynamic var publicId: String = ""
    @objc dynamic var directoryId: String?

}
