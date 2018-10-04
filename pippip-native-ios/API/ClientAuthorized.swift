//
//  ClientAuthorized.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class ClientAuthorized: NSObject, APIResponseProtocol {

    var error: String?
    var sessionId: Int32?
    var authToken: Int64?
    var postId: Int = 0

    var alertPresenter = AlertPresenter()

    required init?(map: Map) {
        if map.JSON["sessionId"] == nil {
            return nil
        }
        if map.JSON["authToken"] == nil {
            return nil
        }
    }
    
    func mapping(map: Map) {

        sessionId <- map["sessionId"]
        error <- map["error"]
        authToken <- map["authToken"]

    }
    
    func processResponse() throws {

        if error != nil {
            alertPresenter.errorAlert(title: "Authentication Error", message: error!)
            throw APIResponseError.responseError(error: error!)
        }

    }
    

}
