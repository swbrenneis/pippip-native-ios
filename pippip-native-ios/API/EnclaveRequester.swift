//
//  EnclaveRequester.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/26/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation
import PromiseKit

class EnclaveRequester<ResponseT: EnclaveResponseProtocol>: NSObject {

    var onResponse: (ResponseT) -> Void
    var onError: (String) -> Void
    var enclaveRequest: EnclaveRequest?
    
    init(onResponse: @escaping (ResponseT) -> Void, onError: @escaping (String) -> Void) {
        
        self.onResponse = onResponse
        self.onError = onError
    }

    // Used after reauthentication
    func doRequest() {
        
        SecommAPI.instance.doPost(request: enclaveRequest!, responseType: EnclaveResponse.self)
        .done { response -> Void in
                do {
                    try response.processResponse()
                    if let methodResponse = ResponseT(JSONString: response.json) {
                        self.onResponse(methodResponse)
                    }
                    else {
                        self.onError("Invalid response JSON")
                    }
                }
                catch {
                    self.onError(error.localizedDescription)
                }
            }
        .catch { error in
                self.onError(error.localizedDescription)
        }
        
    }
    
    func doRequest<RequestT: EnclaveRequestProtocol>(request: RequestT) throws {

        enclaveRequest = EnclaveRequest()
        try enclaveRequest?.setRequest(request)
        SecommAPI.instance.doPost(request: enclaveRequest!, responseType: EnclaveResponse.self)
        .done { response -> Void in
            if response.needsAuth! {
                let reauth = Reauthenticator<ResponseT>()
                reauth.reauthenticate(requester: self)
            }
            else {
                do {
                    try response.processResponse()
                    if let methodResponse = ResponseT(JSONString: response.json) {
                        self.onResponse(methodResponse)
                    }
                    else {
                        self.onError("Invalid response JSON")
                    }
                }
                catch {
                    self.onError(error.localizedDescription)
                }
            }
        }
        .catch { error in
            self.onError(error.localizedDescription)
        }
        
    }

}
