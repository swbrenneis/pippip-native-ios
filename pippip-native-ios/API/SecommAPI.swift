//
//  SecommAPI.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/28/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import CocoaLumberjack
import Promises

struct APIPost {

    var ready: (SecommAPI) -> Void

}

enum PostType {
    case authenticator
    case enclave
}

class SecommAPI {

    static private var theInstance: SecommAPI?
    //static var urlBase: String {
    //    return SecommAPI.apiState.hostPath
    //}

    static var instance: SecommAPI {
        return theInstance!
    }
    var alertPresenter = AlertPresenter()
    var authHostPath: String = ""
    var enclaveHostPath: String = ""
    var sessionPath: String = ""
    var postLock = NSLock()
    var sessionActive = false
    var postId: Int = 0
    var postQueue = [APIPost]()

    static func initializeAPI() {

        theInstance = SecommAPI()
        if AccountSession.production {
            theInstance?.authHostPath = "https://pippip.secomm.cc/authenticator"
            theInstance?.enclaveHostPath = "https://pippip.secomm.cc/enclave"
        }
        else {
            theInstance?.authHostPath = "https://pippip.secomm.cc/test/authenticator"
//            theInstance?.authHostPath = "https://dev.secomm.org:8443/pippip-auth/authenticator"
            theInstance?.enclaveHostPath = "https://dev.secomm.org:8443/pippip-enclave/enclave"
        }
        theInstance?.sessionPath = "/session-request"
        theInstance?.sessionActive = true

    }

    private init() {
        
    }

    func doPost<RequestT: APIRequestProtocol, ResponseT: APIResponseProtocol>(request: RequestT) -> Promise<ResponseT> {
        
        let promise = Promise<ResponseT> { (fulfill, reject) in
            if !self.sessionActive {
                reject(PostError.sessionNotActive)
            }
            
            var resource: String
            switch (request.postType) {
            case .authenticator:
                resource = self.authHostPath + request.path
            case .enclave:
                resource = self.enclaveHostPath + request.path
            }
            if let url = URL(string: resource) {
                var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData,
                                            timeoutInterval: request.timeout)
                urlRequest.httpMethod = HTTPMethod.post.rawValue
                urlRequest.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
                urlRequest.httpBody = request.toJSONString()?.data(using: .utf8, allowLossyConversion: false)
                Alamofire.request(urlRequest).responseObject { (response: DataResponse<ResponseT>) in
                    //if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    //    print("API response: \(utf8Text)")
                    //}
                    
                    if let responseError = response.error {
                        reject(responseError)
                    } else if let postResponse = response.result.value {
                        fulfill(postResponse)
                    } else {
                        reject(PostError.invalidServerResponse)
                    }
                }
            }
            else {
                reject(PostError.invalidResource)
            }
        }

        return promise
        
    }

    /*
    func doPost<DelegateT: APIResponseDelegateProtocol>(delegate: DelegateT) {

        guard sessionActive else { return }

        var resource: String
        switch (delegate.postType) {
        case .authenticator:
            resource = authHostPath + delegate.request.path
        case .enclave:
            resource = enclaveHostPath + delegate.request.path
        }
        if let url = URL(string: resource) {
            var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData,
                                        timeoutInterval: delegate.request.timeout)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            urlRequest.httpBody = delegate.request.toJSONString()?.data(using: .utf8, allowLossyConversion: false)
            Alamofire.request(urlRequest).responseObject { (response: DataResponse<DelegateT.ResponseT>) in
                //print("Request: \(response.request)")
                //print("Response: \(response.response)")
                //print("Error: \(response.error)")
                
                //if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                //    print("API response: \(utf8Text)")
                //}

                DispatchQueue.global().async {
                    if response.error != nil {
                        delegate.responseError(response.error!.localizedDescription)
                        DDLogError("API post failure: \(response.error!)")
                    }
                    else if let postResponse = response.result.value {
                        delegate.responseComplete(postResponse)
                    }
                    else {
                        delegate.responseError("Invalid Server Response")
                    }
                    self.nextPost()
                }
            }
        }
        else {
            DDLogError("Invalid resource: \(resource)")
        }

    }

    func nextPost() {

        postLock.lock()
        postQueue.remove(at: 0)
        postQueue.first?.ready(self)
        postLock.unlock()

    }

    func queuePost<DelegateT: APIResponseDelegateProtocol>(delegate: DelegateT) {

        if sessionActive {
            postLock.lock()
            postQueue.append(APIPost(ready: delegate.ready))
            if postQueue.count == 1 {
                postQueue.first?.ready(self)
            }
            postLock.unlock()
        }

    }
*/
    func startSession(sessionComplete: @escaping (SessionResponse) -> Void) {

        let resource = authHostPath + sessionPath
        if let url = URL(string: resource) {
            var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
            urlRequest.httpMethod = HTTPMethod.get.rawValue
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            Alamofire.request(urlRequest).responseObject { (response: DataResponse<SessionResponse>) in
                //if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                //    print("API response: \(utf8Text)")
                //}
                
                if response.error != nil {
                    self.alertPresenter.errorAlert(title: "Session Error", message: "Unable to establish session with server")
                    DDLogError("API session request failure: \(response.error!)")
                    AsyncNotifier.notify(name: Notifications.ServerUnavailable)
                }
                else if let sessionResponse = response.result.value {
                    self.sessionActive = true
                    sessionComplete(sessionResponse)
                }
                else {
                    DDLogError("Invalid server response in startSession")
                    self.alertPresenter.errorAlert(title: "Session Error", message: "Invalid response from the server")
                    AsyncNotifier.notify(name: Notifications.ServerUnavailable)
                }
            }
        }
        else {
            DDLogError("Invalid resource: \(resource)")
        }

    }

}
