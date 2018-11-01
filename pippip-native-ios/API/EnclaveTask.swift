//
//  EnclaveTask.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/6/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import CocoaLumberjack

class EnclaveTask<RequestT: EnclaveRequestProtocol, ResponseT: EnclaveResponseProtocol>: NSObject {

    var delegate: EnclaveDelegate<RequestT, ResponseT>?
    var errorTitle: String?
    var secommAPI = SecommAPI()
    var alertPresenter = AlertPresenter()
    var request: EnclaveRequestProtocol!
//    var authenticator = ServerAuthenticator()
    var sessionState = SessionState()

    init(delegate: EnclaveDelegate<RequestT, ResponseT>) {

        self.delegate = delegate

        super.init()
        
    }

    func responseComplete(_ response: EnclaveResponse) {
        
        if response.needsAuth! {
            if !sessionState.reauth {
                sessionState.reauth = true
            }
        }
        else {
            if let error = response.processResponse() {
                DDLogError("Enclave response error: \(error)")
                self.delegate?.responseError(error)
            }
            else if let enclaveResponse = ResponseT(JSONString: response.json) {
                self.delegate?.requestComplete(enclaveResponse)
            }
            else {
                DDLogError("Invalid JSON response from server")
                DDLogError(response.json)
                self.delegate?.responseError("Invalid response from the server")
            }
        }
    
    }

    func responseError(error: String) {
        print("Enclave response error: \(error)")
        delegate?.responseError(error)
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
