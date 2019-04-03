//
//  APIRequestProtocol.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation
import ObjectMapper

protocol APIRequestProtocol: Mappable {

    var postType: PostType { get }
    var path: String { get }
    var timeout: Double { get }
    var sessionId: Int32? { set get }
    var authToken: Int64? { get set }

}
