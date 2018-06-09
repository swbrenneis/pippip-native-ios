//
//  EnclaveObserver.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/6/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

enum EnclaveErrors { case invalidServerResponse, invalidEncoding, timedOut }

struct EnclaveResponseError: Error {

    var errorString: String?
    var error: EnclaveErrors?

    init(errorString: String) {
        self.errorString = errorString
    }

}

protocol EnclaveDelegateProtocol {

    associatedtype RequestT
    associatedtype ResponseT

    var request: RequestT { get }
    var requestComplete: ((ResponseT) -> Void)? { get }
    var requestError: ((EnclaveResponseError) -> Void)? { get }

}

class EnclaveDelegate<RequestT: EnclaveRequestProtocol, ResponseT: EnclaveResponseProtocol>: EnclaveDelegateProtocol {
    
    var request: RequestT
    var requestComplete: ((ResponseT) -> Void)?
    var requestError: ((EnclaveResponseError) -> Void)?

    init(request: RequestT) {
        self.request = request
    }

}
