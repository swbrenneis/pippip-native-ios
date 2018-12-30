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
    var secommAPI = SecommAPI.instance
    var alertPresenter = AlertPresenter()
    var request: EnclaveRequestProtocol!
    var serverAuthenticator: ServerAuthenticator?
    var sessionState = SessionState.instance

    init(delegate: EnclaveDelegate<RequestT, ResponseT>) {

        self.delegate = delegate

        super.init()
        
    }

    func responseComplete(_ response: EnclaveResponse) {
        
        if response.needsAuth! {
//            if !sessionState.reauth {
                AccountSession.instance.needsAuth()
                DispatchQueue.global().async {
                    NotificationCenter.default.addObserver(self, selector: #selector(self.reauthComplete(_:)),
                                                           name: Notifications.ReauthComplete, object: nil)
                    self.serverAuthenticator = ServerAuthenticator(authView: nil)
//                    self.serverAuthenticator!.reauthenticate()
                }
//            }
        }
        else {
            do {
                if let error = response.error {
                    DDLogError("Enclave response error: \(error)")
                    self.delegate?.responseError(error)
                }
                else {
                    try response.processResponse()
                    if let enclaveResponse = ResponseT(JSONString: response.json) {
                        self.delegate?.requestComplete(enclaveResponse)
                    }
                    else {
                        DDLogError("Invalid JSON response from server")
                        DDLogError(response.json)
                        self.delegate?.responseError("Invalid response from the server")
                    }
                }
            }
            catch {
                self.delegate?.responseError(error.localizedDescription)
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

    // Notification
    @objc func reauthComplete(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.ReauthComplete, object: nil)
        sendRequest()

    }

}
