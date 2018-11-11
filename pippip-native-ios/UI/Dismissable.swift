//
//  File.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/21/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

protocol Dismissable {
    
    func dismiss()
    func forceDismiss()
    
}

extension Dismissable {
    func forceDismiss() {}
}
