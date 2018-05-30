//
//  APIResponseProtocol.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation
import ObjectMapper

class ResponseError: Error {

    var error: String
    var localizedDescription: String {
        return error
    }

    init(error: String) {
        self.error = error
    }

}

protocol APIResponseProtocol: Mappable {

    var error: String? { get set }

    func processResponse() throws

}

class NullResponse: NSObject, APIResponseProtocol {
    
    var error: String?

    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        error <- map["error"]
    }
    
    func processResponse() throws {
        
    }
    
}
