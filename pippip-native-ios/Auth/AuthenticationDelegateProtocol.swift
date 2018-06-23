//
//  AuthenticationDelegateProtocol.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/22/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

protocol AuthenticationDelegateProtocol {

    func authenticated();
    
    func authenticationFailed(reason: String);

    func loggedOut();

}
