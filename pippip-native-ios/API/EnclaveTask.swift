//
//  EnclaveTask.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/6/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class EnclaveTask<RequestT: EnclaveRequestProtocol, ResponseT: EnclaveResponseProtocol>:
        NSObject, AuthenticationDelegateProtocol {

    var delegate: EnclaveDelegate<RequestT, ResponseT>?
    var errorTitle: String?
    var secommAPI = SecommAPI()
    var alertPresenter = AlertPresenter()
    var request: EnclaveRequestProtocol!
    var authenticator = Authenticator()

    init(delegate: EnclaveDelegate<RequestT, ResponseT>) {

        self.delegate = delegate
        super.init()
        
        authenticator.delegate = self
        
    }

    func responseComplete(_ response: EnclaveResponse) {

        if response.needsAuth! {
            NotificationCenter.default.post(name: Notifications.SessionEnded, object: nil)
            authenticator.reauthenticate()
        }
        else {
            do {
                try response.processResponse()
                if let enclaveResponse = ResponseT(JSONString: response.json) {
                    self.delegate?.requestComplete(enclaveResponse)
                }
                else {
                    print("Invalid JSON response from server")
                    print(response.json)
                    self.delegate?.responseError("Invalid response from the server")
                }
            }
            catch let error as APIResponseError {
                print("Enclave response error: \(error.localizedDescription)")
            }
            catch {
                print("Enclave request unknown error: \(error)")
            }
        }
        
    }

    func responseError(_ error: APIResponseError) {
        print("Enclave response error: \(error.localizedDescription)")
        delegate?.requestError(error.localizedDescription)
    }

    func sendRequest(_ request: EnclaveRequestProtocol) {

        self.request = request
        sendRequest()
        
    }
    
    func sendRequest() {
        
        do {
            let enclaveRequest = EnclaveRequest()
            try enclaveRequest.setRequest(request)
            secommAPI.queuePost(delegate: APIResponseDelegate(request: enclaveRequest,
                                                              responseComplete: self.responseComplete,
                                                              responseError: self.responseError))
        }
        catch {
            print("Error sending enclave request: \(error)")
            delegate?.requestError("Unable to create request")
        }
        
    }

    // Authentication delegate
    
    func authenticated() {
        
        sendRequest()

    }

    func authenticationFailed(reason: String) {
        print("Reauthentication failure: \(reason)")
        delegate?.requestError("Couldn't authenticate session")
    }

    func loggedOut() {
        // Nothing to do
    }

}
