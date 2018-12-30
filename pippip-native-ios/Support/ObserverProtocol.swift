//
//  ObserverProtocol.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/26/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

protocol ObserverProtocol: NSObjectProtocol {
    
    func update(observable: ObservableProtocol, object: Any?)
    
}
