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
    var postType: PostType { get }

    func ready(api: SecommAPI)

}

class APIResponseDelegate<RequestT:APIRequestProtocol, ResponseT:APIResponseProtocol>: APIResponseDelegateProtocol {
    

    var request: RequestT
    var responseComplete: (ResponseT) -> Void
    var responseError: (String) -> Void
    var postType: PostType
    init(request: RequestT, postType: PostType, responseComplete: @escaping (ResponseT) -> Void,
         responseError: @escaping (String) -> Void) {
        self.request = request
        self.postType = postType
        self.responseComplete = responseComplete
        self.responseError = responseError
    }

    func ready(api: SecommAPI) {
//        api.doPost(delegate: self)
    }

}
