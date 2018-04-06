//
//  EnclaveTask.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/6/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class EnclaveTask: NSObject, RequestProcessProtocol {

    var postPacket: PostPacket?
    var errorDelegate: ErrorDelegate
    var completion: ([AnyHashable: Any]) -> Void

    init(_ completion: @escaping ([AnyHashable: Any]) -> Void) {

        errorDelegate = NotificationErrorDelegate("Message Error")
        self.completion = completion

        super.init()

    }

    func sessionComplete(_ response: [AnyHashable : Any]?) {
        // Nothing to do
    }

    func postComplete(_ response: [AnyHashable : Any]?) {

        if let _ = response {
            let enclaveResponse = EnclaveResponse()
            if enclaveResponse.processResponse(response, errorDelegate: errorDelegate) {
                completion(enclaveResponse.getResponse())
            }
        }
    }

    func sendRequest(_ request: [AnyHashable: Any]) {

        let session = ApplicationSingleton.instance().restSession
        let enclaveRequest = EnclaveRequest()
        enclaveRequest.setRequest(request)
        postPacket = enclaveRequest
        session?.queuePost(self)
        
    }

}
