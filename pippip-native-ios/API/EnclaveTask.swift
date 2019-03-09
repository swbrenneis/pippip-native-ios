//
//  EnclaveTask.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/6/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import CocoaLumberjack
import Promises

class EnclaveTask<RequestT: EnclaveRequestProtocol, ResponseT: EnclaveResponseProtocol>: NSObject {

    var delegate: EnclaveDelegate<RequestT, ResponseT>?
    var errorTitle: String?
    var alertPresenter = AlertPresenter()
    var request: EnclaveRequestProtocol!
    var serverAuthenticator: ServerAuthenticator?
    var sessionState = SessionState()

    init(delegate: EnclaveDelegate<RequestT, ResponseT>) {

        self.delegate = delegate

        super.init()
        
    }

    func responseComplete(_ response: EnclaveResponse) {
        
        if response.needsAuth! {
//            if !sessionState.reauth {
                // reauthentication latch
                sessionState.reauth = true
                AccountSession.instance.needsAuth()
                DispatchQueue.global().async {
                    NotificationCenter.default.addObserver(self, selector: #selector(self.reauthComplete(_:)),
                                                           name: Notifications.ReauthComplete, object: nil)
                    self.serverAuthenticator = ServerAuthenticator(authView: nil)
                    self.serverAuthenticator!.reauthenticate()
                }
//            }
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
        DDLogError("Enclave response error: \(error)")
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
            let promise: Promise<EnclaveResponse> = SecommAPI.instance.doPost(request: enclaveRequest)
            promise.then { response in
                self.responseComplete(response)
            }.catch { error in
                self.responseError(error: error.localizedDescription)
            }
        } catch {
            DDLogError("Error sending enclave request: \(error)")
            delegate?.requestError("Unable to create request")
        }
        
    }

    // Notification
    @objc func reauthComplete(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.ReauthComplete, object: nil)
        sendRequest()

    }

}
