//
//  NotificationErrorDelegate.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/23/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

@objc class NotificationErrorDelegate: NSObject, ErrorDelegate {

    private var alert: UIAlertController
    private var info: [AnyHashable: Any]

    @objc init(title: String) {

        alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil);
        alert.addAction(okAction)
        info = [ "alert" : alert ]

    }

    func getMethodError(_ error: String) {
        
        alert.message = error;
        NotificationCenter.default.post(name: Notifications.PresentAlert, object: nil, userInfo: info)
        
    }
    
    func postMethodError(_ error: String) {
        
        alert.message = error;
        NotificationCenter.default.post(name: Notifications.PresentAlert, object: nil, userInfo: info)
        
    }
    
    func responseError(_ error: String) {
        
        alert.message = error;
        NotificationCenter.default.post(name: Notifications.PresentAlert, object: nil, userInfo: info)
        
    }
    
    func sessionError(_ error: String) {
        
        alert.message = error;
        NotificationCenter.default.post(name: Notifications.PresentAlert, object: nil, userInfo: info)
        
    }
    
}
