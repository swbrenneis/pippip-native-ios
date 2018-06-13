//
//  APIResponseProtocol.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation
import ObjectMapper

enum ResponseErrors { case timedout, invalidServerResponse, invalidSession, invalidAuthToken, invalidRequest }

class APIResponseError: Error {

    var errorString: String?
    var error: ResponseErrors?
    
    init(errorString: String) {
        self.errorString = errorString
    }

}

protocol APIResponseProtocol: Mappable {

    var error: String? { get set }
    var sessionId: Int32? { get set }
    var authToken: Int64? { get set }
    var postId: Int { get set }

    func processResponse() throws

}

class NullResponse: NSObject, APIResponseProtocol {

    var error: String?
    var sessionId: Int32?
    var authToken: Int64?
    var postId: Int = 0

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        error <- map["error"]
    }

    func processResponse() throws {

    }

}