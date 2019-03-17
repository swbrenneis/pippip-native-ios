//
//  APIResponseProtocol.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation
import ObjectMapper

protocol APIResponseProtocol: Mappable {

    var error: String? { get }
    var sessionId: Int32? { get }
    var authToken: Int64? { get }

    func processResponse() throws

}

class NullResponse: NSObject, APIResponseProtocol {

    var error: String?
    var sessionId: Int32?
    var authToken: Int64?

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        error <- map["error"]
    }

    func processResponse() throws {
    }

}
