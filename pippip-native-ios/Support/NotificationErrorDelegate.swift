//
//  NotificationErrorDelegate.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/23/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

@objc class NotificationErrorDelegate: NSObject, ErrorDelegate {

    private var info: [AnyHashable: Any]

    @objc init(_ title: String) {

        info = [ "title" : title ]

    }

    func getMethodError(_ error: String) {

        info["message"] = error
        NotificationCenter.default.post(name: Notifications.PresentAlert, object: nil, userInfo: info)
        
    }
    
    func postMethodError(_ error: String) {
        
        info["message"] = error
        NotificationCenter.default.post(name: Notifications.PresentAlert, object: nil, userInfo: info)
        
    }

    func responseError(_ error: String) {
        
        info["message"] = error
        NotificationCenter.default.post(name: Notifications.PresentAlert, object: nil, userInfo: info)
        
    }
    
    func requestError(_ error: String) {
        
        info["message"] = error
        NotificationCenter.default.post(name: Notifications.PresentAlert, object: nil, userInfo: info)
        
    }
    
    func sessionError(_ error: String) {
        
        info["message"] = error
        NotificationCenter.default.post(name: Notifications.PresentAlert, object: nil, userInfo: info)
        
    }
    
}
