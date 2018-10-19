//
//  AsyncNotifier.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/24/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

@objc class AsyncNotifier: NSObject {

    @objc(notifyWithName:object:userInfo:)
    class func notify(_ name: String, object: Any?, userInfo: NSDictionary?) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            NotificationCenter.default.post(name: NSNotification.Name(name),
                                            object: object, userInfo: userInfo as? [AnyHashable: Any])
        }
        
    }
    
    class func notify(_ name: String, toast: Bool = false) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            NotificationCenter.default.post(name: NSNotification.Name(name), object: toast, userInfo: nil)
        }
        
    }

    class func notify(name: NSNotification.Name, toast: Bool = false) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            NotificationCenter.default.post(name: name, object: toast, userInfo: nil)
        }
        
    }

    class func notify(name: NSNotification.Name, userInfo: [String: Any], toast: Bool = false) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            NotificationCenter.default.post(name: name, object: toast, userInfo: userInfo)
        }
        
    }

    class func notify(name: NSNotification.Name, object: Any?) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            NotificationCenter.default.post(name: name, object: object, userInfo: nil)
        }
        
    }
    
}
