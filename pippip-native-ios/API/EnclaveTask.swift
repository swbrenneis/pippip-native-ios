//
//  EnclaveTask.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/6/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class EnclaveTask<RequestT: EnclaveRequestProtocol, ResponseT: EnclaveResponseProtocol>: NSObject {

    var delegate: EnclaveDelegate<RequestT, ResponseT>?
    var errorTitle: String?
    var secommAPI = SecommAPI()
    var alertPresenter = AlertPresenter()

    init(delegate: EnclaveDelegate<RequestT, ResponseT>) {
        self.delegate = delegate
        super.init()
    }

    func postComplete(_ response: EnclaveResponse) {

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try response.processResponse()
                if let enclaveResponse = ResponseT(JSONString: response.json!) {
                    self.delegate?.requestComplete!(enclaveResponse)
                }
                else {
                    print("Invalid JSON response from server")
                    print(response.json!)
                    self.delegate?.requestError!(EnclaveResponseError(errorString: "Invalid server response"))
                }
            }
            catch let error as APIResponseError {
                print("Enclave request error: \(error.error)")
            }
            catch {
                print("Enclave request unknown error: \(error)")
            }
        }
        
    }

    func postError(_ error: APIResponseError) {
        print("Enclave request post error: \(error.errorString)")
        delegate?.requestError!(EnclaveResponseError(errorString: error.errorString))
    }

    func sendRequest(_ request: EnclaveRequestProtocol) {

        do {
            let enclaveRequest = EnclaveRequest()
            try enclaveRequest.setRequest(request)
            secommAPI.queuePost(delegate: APIResponseDelegate(request: enclaveRequest,
                                                              responseComplete: self.postComplete,
                                                              responseError: self.postError))
        }
        catch {
            print("Error sending enclave request: \(error)")
            alertPresenter.errorAlert(title: errorTitle!, message: "Unable to create request")
        }
        
    }

}
