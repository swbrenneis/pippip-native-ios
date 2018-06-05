//
//  PostObserverProtocol.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

protocol PostObserverProtocol {

    associatedtype ResponseT: APIResponseProtocol

    var request: APIRequestProtocol { get }
    var postComplete: (ResponseT) -> Void { get }
    var postError: (Error) -> Void { get }

}

class PostObserver<RequestT:APIRequestProtocol, ResponseT:APIResponseProtocol>: PostObserverProtocol {
    var request: APIRequestProtocol
    var postComplete: (ResponseT) -> Void
    var postError: (Error) -> Void
    init(request: RequestT, postComplete: @escaping (ResponseT) -> Void, postError: @escaping (Error) -> Void) {
        self.request = request
        self.postComplete = postComplete
        self.postError = postError
    }
}
