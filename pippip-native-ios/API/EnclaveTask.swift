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

class EnclaveTask<RequestT: EnclaveRequestProtocol, ResponseT: EnclaveResponseProtocol> {

    var errorTitle: String?
    var alertPresenter = AlertPresenter()
    var reauthenticator: Reauthenticator<RequestT, ResponseT>?
    var request: RequestT?
    var promise: Promise<ResponseT>?
    var serverAuthenticator: ServerAuthenticator?
    var sessionState = SessionState()

    func processResponse(response: EnclaveResponse) throws -> ResponseT {
        
        if response.needsAuth! {
            sessionState.reauth = true
            AccountSession.instance.needsAuth()
            DispatchQueue.main.async {
                self.reauthenticator?.authenticate()
            }
            throw EnclaveError.needsAuthentication
        }
        
        try response.processResponse()
        if let enclaveResponse = ResponseT(JSONString: response.json) {
            return enclaveResponse
        } else {
            throw EnclaveError.invalidServerResponse
        }

    }
    
    func resendRequest() {
        
        do {
            let enclaveRequest = EnclaveRequest()
            try enclaveRequest.setRequest(request!)
            let apiPromise: Promise<EnclaveResponse> = SecommAPI.instance.doPost(request: enclaveRequest)
            apiPromise.then { response in
                do {
                    let methodResponse = try self.processResponse(response: response)
                    self.promise?.fulfill(methodResponse)
                } catch EnclaveError.needsAuthentication {
                    // Not really an exception, reauthentication is happening asynchronously on the main thread
                    DDLogInfo(Strings.infoNeedsAuth)
                } catch {
                    self.promise?.reject(error)
                }
            } .catch { error in
                self.promise?.reject(error)
            }
        } catch {
            DDLogError("Error sending enclave request: \(error.localizedDescription)")
            promise?.reject(error)
        }

    }
    
    func sendRequest(request: RequestT) -> Promise<ResponseT> {

        reauthenticator = Reauthenticator(task: self)

        self.request = request
        promise = Promise<ResponseT> { (fulfill, reject) in
            do {
                let enclaveRequest = EnclaveRequest()
                try enclaveRequest.setRequest(request)
                let apiPromise: Promise<EnclaveResponse> = SecommAPI.instance.doPost(request: enclaveRequest)
                apiPromise.then { response in
                    do {
                        let methodResponse = try self.processResponse(response: response)
                        fulfill(methodResponse)
                    } catch EnclaveError.needsAuthentication {
                        // Not really an exception, reauthentication is happening asynchronously on the main thread
                        DDLogInfo(Strings.infoNeedsAuth)
                    } catch {
                        reject(error)
                    }
                }
                .catch { error in
                    reject(error)
                }
            } catch {
                DDLogError("Error sending enclave request: \(error.localizedDescription)")
                reject(error)
            }

        }
        return promise!

    }

}
