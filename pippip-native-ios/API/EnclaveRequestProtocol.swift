//
//  EnclaveRequestProtocol.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation
import ObjectMapper

protocol EnclaveRequestProtocol: Mappable {

    var method: String { get set }
    var version: Float? { get set }

}
