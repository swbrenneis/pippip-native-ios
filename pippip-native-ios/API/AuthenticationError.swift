//
//  AuthenticationError.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/10/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import Foundation

enum AuthenticationError : Error {
    case invalidSignature
    case challengeFailed
}
