//
//  EnclaveObserver.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/6/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
/*
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
    func requestComplete(response: ResponseT)
    func requestError(error: String)
    func responseError(error: String)

}
*/
class EnclaveDelegate<RequestT: EnclaveRequestProtocol, ResponseT: EnclaveResponseProtocol> /*: EnclaveDelegateProtocol */ {
    
    var request: RequestT

    init(request: RequestT) {
        self.request = request
    }

    func requestComplete(response: ResponseT) {}
    func requestError(error: String) {}
    func responseError(error: String) {}

}
