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

struct APIState {
    
    var hostPath: String = ""
    var sessionPath: String = ""
    var postLock = NSLock()
    var sessionActive = false
    var postId: Int = 0

}

class SecommAPI: NSObject {

    static private var apiState = APIState()
    static var urlBase: String {
        return SecommAPI.apiState.hostPath
    }

    var alertPresenter = AlertPresenter()

    static func initializeAPI() {

        if AccountManager.production() {
            SecommAPI.apiState.hostPath = "https://pippip.secomm.cc"
            SecommAPI.apiState.sessionPath = "/authenticator/session-request"
        }
        else {
            SecommAPI.apiState.hostPath = "https://dev.secomm.org:8443/secomm-api-rest-1.1.0"
            SecommAPI.apiState.sessionPath = "/session-request"
        }
        SecommAPI.apiState.sessionActive = true

    }

    @discardableResult
    func doPost<ObserverT: PostObserverProtocol>(observer: ObserverT) -> Int {

        guard SecommAPI.apiState.sessionActive else { return -1 }
        
        SecommAPI.apiState.postLock.lock()
        var postId = -1
        let resource = SecommAPI.apiState.hostPath + observer.request.path
        if let url = URL(string: resource) {
            var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData,
                                        timeoutInterval: observer.request.timeout)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            urlRequest.httpBody = observer.request.toJSONString()?.data(using: .utf8, allowLossyConversion: false)
            SecommAPI.apiState.postId += 1
            postId = SecommAPI.apiState.postId
            Alamofire.request(urlRequest).responseObject { (response: DataResponse<ObserverT.ResponseT>) in
                if response.error != nil {
                    observer.postError(response.error!)
                    print("API post failure: \(response.error!)")
                }
                else if var postResponse = response.result.value {
                    postResponse.postId = postId
                    observer.postComplete(postResponse)
                }
                else {
                    print("Invalid server response in doPost")
                    self.alertPresenter.errorAlert(title: "Request Error", message: "Invalid response from the server")
                }
            }
        }
        else {
            print("Invalid resource: \(resource)")
        }

        defer {
            SecommAPI.apiState.postLock.unlock()
        }
        
        return postId

    }

    @discardableResult
    func doxPost<ResponseT: Mappable>(responseType: ResponseT.Type, request: APIRequestProtocol) -> Int {

        guard SecommAPI.apiState.sessionActive else { return -1 }

        SecommAPI.apiState.postLock.lock()
        var postId = -1
        let resource = SecommAPI.apiState.hostPath + request.path
        if let url = URL(string: resource) {
            var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData,
                                        timeoutInterval: request.timeout)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            urlRequest.httpBody = request.toJSONString()?.data(using: .utf8, allowLossyConversion: false)
            SecommAPI.apiState.postId += 1
            postId = SecommAPI.apiState.postId
            Alamofire.request(urlRequest).responseObject { (response: DataResponse<ResponseT>) in
                if response.error != nil {
                    self.alertPresenter.errorAlert(title: "Request Error", message: "Unable to send request")
                    print("API post failure: \(response.error!)")
                }
                else if var postResponse = response.result.value as? APIResponseProtocol {
                    postResponse.postId = postId
                    NotificationCenter.default.post(name: Notifications.PostComplete, object: postResponse, userInfo: nil)
                }
                else {
                    print("Invalid server response in doPost")
                    self.alertPresenter.errorAlert(title: "Request Error", message: "Invalid response from the server")
                }
            }
        }
        else {
            print("Invalid resource: \(resource)")
        }

        defer {
            SecommAPI.apiState.postLock.unlock()
        }

        return postId

    }

    func startSession() {

        let resource = SecommAPI.apiState.hostPath + SecommAPI.apiState.sessionPath
        if let url = URL(string: resource) {
            var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
            urlRequest.httpMethod = HTTPMethod.get.rawValue
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            Alamofire.request(urlRequest).responseObject { (response: DataResponse<SessionResponse>) in
                if response.error != nil {
                    self.alertPresenter.errorAlert(title: "Session Error", message: "Unable to establish session with server")
                    print("API session request failure: \(response.error!)")
                }
                else if let sessionResponse = response.result.value {
                    SecommAPI.apiState.sessionActive = true
                    NotificationCenter.default.post(name: Notifications.SessionStarted, object: sessionResponse, userInfo: nil)
                }
                else {
                    print("Invalid server response in startSession")
                    self.alertPresenter.errorAlert(title: "Session Error", message: "Invalid response from the server")
                }
            }
        }
        else {
            print("Invalid resource: \(resource)")
        }

    }

}
