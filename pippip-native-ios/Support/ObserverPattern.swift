//
//  ObserverPattern.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/27/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import Foundation

protocol PippipObservable {
    
    func addObserver(observer: PippipObserver, action: @escaping (Any?) -> Void);
    func removeObserver(observer: PippipObserver);
    
}

protocol PippipObserver {
    
}
