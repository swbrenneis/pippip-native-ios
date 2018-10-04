//
//  PostObserverProtocol.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

protocol APIResponseDelegateProtocol {

    associatedtype ResponseT: APIResponseProtocol
    associatedtype RequestT: APIRequestProtocol

    var request: RequestT { get }
    var responseComplete: (ResponseT) -> Void { get }
    var responseError: (String) -> Void { get }

    func ready(api: SecommAPI)

}

class APIResponseDelegate<RequestT:APIRequestProtocol, ResponseT:APIResponseProtocol>: APIResponseDelegateProtocol {

    var request: RequestT
    var responseComplete: (ResponseT) -> Void
    var responseError: (String) -> Void
    init(request: RequestT, responseComplete: @escaping (ResponseT) -> Void,
         responseError: @escaping (String) -> Void) {
        self.request = request
        self.responseComplete = responseComplete
        self.responseError = responseError
    }

    func ready(api: SecommAPI) {
        api.doPost(delegate: self)
    }

}
