//
//  SwiftErrorDelegate.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/22/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

@objc protocol ErrorDelegate {

    @objc func getMethodError(_: String)

    @objc func postMethodError(_: String)

    @objc func responseError(_: String)

    @objc func sessionError(_: String)

}
