//
//  RequestProcessProtocol.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/5/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

@objc protocol RequestProcessProtocol {

    var postPacket: PostPacket? { get }
    var errorDelegate: ErrorDelegate { get }

    func sessionComplete(_ response:[AnyHashable: Any]?)

    func postComplete(_ response:[AnyHashable: Any]?)

}

