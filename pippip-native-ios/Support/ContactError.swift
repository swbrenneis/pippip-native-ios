//
//  ContactError.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/20/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ContactError: Error {

    private var error = ""
    var localizedDescription: String {
        return error
    }
    
    init(error: String) {
        self.error = error
    }
    
}
