//
//  PostPacketProtocol.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/14/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

@objc protocol PostPacketProtocol {

    var restPath: String { get }
    var restPacket: [String: Any] { get }
    var restTimeout: Double { get }

}
