//
//  ApplicationInitializer.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/28/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ApplicationInitializer: NSObject {

    @objc static var accountSession = AccountSession.instance

    @objc static func InitializeApp() {

        SecommAPI.initializeAPI()

    }

}
