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
import PromiseKit

struct APIPost {

    var ready: (SecommAPI) -> Void

}

struct APIState {
    
    var hostPath: String = ""
    var sessionPath: String = ""
    var postLock = NSLock()
    var sessionActive = false
    var postId: Int = 0
    var postQueue = [APIPost]()

}

class SecommAPI: NSObject {

    static private var theInstance: SecommAPI?

    static var instance: SecommAPI {
        get {
            if let api = SecommAPI.theInstance {
                return api
            }
            else {
                let api = SecommAPI()
                SecommAPI.theInstance = api
                return api
            }
        }
    }
    
    private override init() {

        if AccountSession.production {
            hostPath = "https://pippip.secomm.cc"
            sessionPath = "/authenticator/session-request"
        }
        else {
            hostPath = "https://dev.secomm.org:8443/secomm-api-rest-2.0.1"
            sessionPath = "/session-request"
        }
        
    }
    
    var urlBase: String {
        return hostPath
    }

    var hostPath: String = ""
    var sessionPath: String = ""
    var postLock = NSLock()
    var sessionActive = false
    var postId: Int = 0
    var postQueue = [APIPost]()
    
    var alertPresenter = AlertPresenter()
    var sessionObserver: SessionObserverProtocol?
    
    func doPost<DelegateT: APIResponseDelegateProtocol>(delegate: DelegateT) {

        guard sessionActive else { return }

        let resource = hostPath + delegate.request.path
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
    
    func doPost<RequestT: APIRequestProtocol, ResponseT:APIResponseProtocol>(request: RequestT, responseType: ResponseT.Type) -> Promise<ResponseT> {
        
        if !sessionActive {
            return Promise { seal in
                seal.reject(APIError.illegalState)
            }
        }
        
        let resource = hostPath + request.path
        if let url = URL(string: resource) {
            return Promise { seal in
                var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData,
                                            timeoutInterval: request.timeout)
                urlRequest.httpMethod = HTTPMethod.post.rawValue
                urlRequest.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
                urlRequest.httpBody = request.toJSONString()?.data(using: .utf8, allowLossyConversion: false)
                Alamofire.request(urlRequest).validate().responseObject { (response: DataResponse<ResponseT>) in
                    if let responseError = response.error {
                        seal.reject(responseError)
                    }
                    else if let postResponse = response.value {
                        seal.fulfill(postResponse)
                    }
                    else {
                        seal.reject(ServerResponseError.invalidServerResponse)
                    }
                }
            }
        }
        else {
            return Promise { seal in
                seal.reject(APIError.invalidResource)
            }
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

    func startSession() -> Promise<SessionResponse> {
        
        let resource = hostPath + sessionPath
        if let url = URL(string: resource) {
            return Promise { seal in
                var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
                urlRequest.httpMethod = HTTPMethod.get.rawValue
                urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
                Alamofire.request(urlRequest).responseObject { (response: DataResponse<SessionResponse>) in
                    if let responseError = response.error {
                        seal.reject(responseError)
                    }
                    else if let sessionResponse = response.value {
                        seal.fulfill(sessionResponse)
                    }
                    else {
                        seal.reject(ServerResponseError.invalidServerResponse)
                    }
                }
            }
        }
        else {
            DDLogError("Invalid resource: \(resource)")
            return Promise { seal in
                seal.reject(APIError.invalidResource)
            }
        }

    }
/*
    func startSession(sessionObserver: SessionObserverProtocol) {

        self.sessionObserver = sessionObserver
        let resource = hostPath + sessionPath
        if let url = URL(string: resource) {
            var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
            urlRequest.httpMethod = HTTPMethod.get.rawValue
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            Alamofire.request(urlRequest).responseObject { (response: DataResponse<SessionResponse>) in
                if response.error != nil {
                    self.alertPresenter.errorAlert(title: "Session Error", message: "Unable to establish session with server")
                    DDLogError("API session request failure: \(response.error!)")
                    AsyncNotifier.notify(name: Notifications.ServerUnavailable)
                }
                else if let sessionResponse = response.result.value {
                    self.sessionActive = true
                    sessionObserver.sessionStarted(sessionResponse: sessionResponse)
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
*/
}
