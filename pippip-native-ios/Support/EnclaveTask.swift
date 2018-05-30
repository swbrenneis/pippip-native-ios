//
//  EnclaveTask.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/6/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class EnclaveTask: NSObject {

    var completion: (String) -> Void
    var errorTitle: String?
    var postId: Int
    var secommAPI = SecommAPI()
    var alertPresenter = AlertPresenter()

    init(_ completion: @escaping (String) -> Void) {

        self.completion = completion
        postId = -1

        super.init()

    }

    @objc func postComplete(_ notification: Notification) {

        guard let response = notification.object as? EnclaveResponse else { return }
        if response.postId == postId {
            NotificationCenter.default.removeObserver(self, name: Notifications.PostComplete, object: nil)
            
            DispatchQueue.global().async {
                do {
                    try response.processResponse()
                    NotificationCenter.default.post(name: Notifications.EnclaveRequestComplete, object: response.json!)
                }
                catch {
                    print("Enclave request error: \(error)")
                }
            }
        }
        
    }

    func sendRequest(_ request: APIRequestProtocol) {

        do {
            let enclaveRequest = EnclaveRequest()
            try enclaveRequest.setRequest(request)
            NotificationCenter.default.addObserver(self, selector: #selector(postComplete(_:)),
                                                   name: Notifications.PostComplete, object: nil)
            postId = secommAPI.doPost(responseType: EnclaveResponse.self, request: request)
        }
        catch {
            print("Error sending enclave request: \(error)")
            alertPresenter.errorAlert(title: errorTitle!, message: "Unable to create request")
        }
        
    }

}
