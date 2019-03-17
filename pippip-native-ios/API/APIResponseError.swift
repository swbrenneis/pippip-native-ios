//
//  APIResponseError.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/10/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import Foundation

enum APIResponseError : Error {
    case invalidAuth
    case invalidServerResponse
    case serverResponseError(error: String)
}
