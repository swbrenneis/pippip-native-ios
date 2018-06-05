//
//  CryptoError.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class CryptoError: Error {

    private var error = ""
    var localizedDescription: String {
        return error
    }

    init(error: String) {
        self.error = error
    }

}
