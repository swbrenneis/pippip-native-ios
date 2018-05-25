//
//  EnclaveTask.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/6/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class EnclaveTask: NSObject, RequestProcessProtocol {

    var postPacket: PostPacketProtocol?
    var errorDelegate: ErrorDelegate
    var completion: ([AnyHashable: Any]) -> Void
    var errorTitle : String? {
        didSet {
            errorDelegate = NotificationErrorDelegate(title: errorTitle!)
        }
    }

    init(_ completion: @escaping ([AnyHashable: Any]) -> Void) {

        errorDelegate = NotificationErrorDelegate(title: "Unknown")
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

    func sendRequest(_ request: [String: Any]) {

        do {
            let session = ApplicationSingleton.instance().restSession
            let enclaveRequest = EnclaveRequest()
            try enclaveRequest.setRequest(request)
            postPacket = enclaveRequest
            session?.queuePost(self)
        }
        catch {
            print("Error sending enclave request: \(error)")
            errorDelegate.requestError("Failed to send request")
        }
        
    }

}
