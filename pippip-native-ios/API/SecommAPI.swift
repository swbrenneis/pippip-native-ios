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

    static private var apiState = APIState()
    static var urlBase: String {
        return SecommAPI.apiState.hostPath
    }

    var alertPresenter = AlertPresenter()
    var sessionObserver: SessionObserverProtocol?

    static func initializeAPI() {

        if AccountSession.production {
            SecommAPI.apiState.hostPath = "https://pippip.secomm.cc"
            SecommAPI.apiState.sessionPath = "/authenticator/session-request"
        }
        else {
            SecommAPI.apiState.hostPath = "https://dev.secomm.org:8443/secomm-api-rest-2.0.1"
            SecommAPI.apiState.sessionPath = "/session-request"
        }
        SecommAPI.apiState.sessionActive = true

    }

    func doPost<DelegateT: APIResponseDelegateProtocol>(delegate: DelegateT) {

        guard SecommAPI.apiState.sessionActive else { return }

        let resource = SecommAPI.apiState.hostPath + delegate.request.path
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

        SecommAPI.apiState.postLock.lock()
        SecommAPI.apiState.postQueue.remove(at: 0)
        SecommAPI.apiState.postQueue.first?.ready(self)
        SecommAPI.apiState.postLock.unlock()

    }

    func queuePost<DelegateT: APIResponseDelegateProtocol>(delegate: DelegateT) {

        if SecommAPI.apiState.sessionActive {
            SecommAPI.apiState.postLock.lock()
            SecommAPI.apiState.postQueue.append(APIPost(ready: delegate.ready))
            if SecommAPI.apiState.postQueue.count == 1 {
                SecommAPI.apiState.postQueue.first?.ready(self)
            }
            SecommAPI.apiState.postLock.unlock()
        }

    }

    func startSession(sessionObserver: SessionObserverProtocol) {

        self.sessionObserver = sessionObserver
        let resource = SecommAPI.apiState.hostPath + SecommAPI.apiState.sessionPath
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
                    SecommAPI.apiState.sessionActive = true
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

}
