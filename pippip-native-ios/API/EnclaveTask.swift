//
//  EnclaveTask.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/6/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class EnclaveTask<ResponseT: EnclaveResponseProtocol>: NSObject {

    var completion: (ResponseT) -> Void
    var errorTitle: String?
    var postId: Int
    var secommAPI = SecommAPI()
    var alertPresenter = AlertPresenter()

    init(_ completion: @escaping (ResponseT) -> Void) {

        self.completion = completion
        postId = -1

        super.init()

    }

    func postComplete(_ response: EnclaveResponse) {

        if response.postId == postId {
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try response.processResponse()
                    if let enclaveResponse = ResponseT(JSONString: response.json!) {
                        self.completion(enclaveResponse)
                    }
                    else {
                        print("Invalid JSON response from server")
                        print(response.json!)
                    }
                }
                catch {
                    print("Enclave request error: \(error)")
                }
            }
        }
        
    }

    func postError(_ error: Error) {
        print("Enclave request post error: \(error)")
    }

    func sendRequest(_ request: EnclaveRequestProtocol) {

        do {
            let enclaveRequest = EnclaveRequest()
            try enclaveRequest.setRequest(request)
            postId = secommAPI.doPost(observer: PostObserver(request: enclaveRequest,
                                                             postComplete: self.postComplete,
                                                             postError: self.postError))
        }
        catch {
            print("Error sending enclave request: \(error)")
            alertPresenter.errorAlert(title: errorTitle!, message: "Unable to create request")
        }
        
    }

}
