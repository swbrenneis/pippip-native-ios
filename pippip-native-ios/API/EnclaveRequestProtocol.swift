//
//  EnclaveRequestProtocol.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation
import ObjectMapper

struct EnclaveRequestError: Error {

    private var errorString = "Unknown"
    var localizedDescription: String {
        return errorString
    }

    init(errorString: String) {
        self.errorString = errorString
    }

}

protocol EnclaveRequestProtocol: Mappable {

    var method: String { get set }

}
