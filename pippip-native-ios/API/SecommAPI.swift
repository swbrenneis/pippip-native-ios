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

struct APIState {
    
    var hostPath: String = ""
    var sessionPath: String = ""
    var processes = [RequestProcessProtocol]()
    var currentProcess: RequestProcessProtocol?
    var postLock = NSLock()
    var sessionActive = false

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

    func doPost() {
        
        let process = SecommAPI.apiState.currentProcess!
        let resource = SecommAPI.apiState.hostPath + process.postPacket!.restPath
        let postPacket = SecommAPI.apiState.currentProcess!.postPacket
        if let url = URL(string: resource) {
            var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: postPacket?.restTimeout)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        }
        else {
            print("Invalid resource: \(resource)")
        }

    }

    func queuePost(_ process: RequestProcessProtocol) {

        if SecommAPI.apiState.sessionActive {
            SecommAPI.apiState.postLock.lock()
            SecommAPI.apiState.processes.append(process)
            if SecommAPI.apiState.processes.count == 1 {
                SecommAPI.apiState.currentProcess = process
                doPost()
            }
            defer {
                SecommAPI.apiState.postLock.unlock()
            }
        }

    }

    @objc func startSession() {

        let resource = SecommAPI.apiState.hostPath + SecommAPI.apiState.sessionPath
        Alamofire.request(resource, method: .post).responseObject { (response: DataResponse<SessionResponse>) in
            if response.error != nil {
                self.alertPresenter.errorAlert(title: "Session Error", message: "Unable to establish session with server")
                print("API session request failure: \(response.error!)")
            }
            else if let sessionResponse = response.result.value {
                NotificationCenter.default.post(name: Notifications.SessionStarted, object: sessionResponse, userInfo: nil)
            }
            else {
                print("Invalid server response in startSession")
                self.alertPresenter.errorAlert(title: "Session Error", message: "Invalid response from the server")
            }
        }

    }

}
