//
//  EnclaveTaskObserver.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/26/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

protocol EnclaveTaskObserverProtocol {

    associatedtype ResponseT;
    
    func onResponse(response: ResponseT);
    
    func onError(error: String);

}
