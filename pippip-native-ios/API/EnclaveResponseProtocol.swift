//
//  EnclaveResponseProtocol.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation
import ObjectMapper

protocol EnclaveResponseProtocol: Mappable {
    
    var error: String? { get }
    var version: Float? { get set }
    var json: String? { get }

    init?(jsonString: String)
    
}
