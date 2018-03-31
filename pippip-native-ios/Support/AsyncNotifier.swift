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
    
    class func notify(_ name: String) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            NotificationCenter.default.post(name: NSNotification.Name(name), object: nil, userInfo: nil)
        }
        
    }
    
}
