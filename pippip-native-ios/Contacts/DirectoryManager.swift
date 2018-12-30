//
//  DirectoryManager.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/26/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation
import PromiseKit
import CocoaLumberjack

class DirectoryManager: NSObject {

    var alertPresenter = AlertPresenter();
    
    func matchDirectoryId(directoryId: String?, publicId: String?,
                          onResponse: @escaping (MatchDirectoryIdResponse) -> Void,
                          onError: @escaping (String) -> Void) {
        
        let requester = EnclaveRequester(onResponse: onResponse, onError: onError)
        let request = MatchDirectoryIdRequest(publicId: publicId, directoryId: directoryId)
        do {
            try requester.doRequest(request: request)
        }
        catch {
            DDLogError("Match directory ID error: \(error.localizedDescription)")
        }
        
    }
    
    func setDirectoryId(oldId: String, newId: String,
                        onResponse: @escaping (SetDirectoryIdResponse) -> Void,
                        onError: @escaping (String) -> Void) {

        let requester = EnclaveRequester(onResponse: onResponse, onError: onError)
        let request = SetDirectoryIdRequest(oldDirectoryId: oldId, newDirectoryId: newId)
        do {
            try requester.doRequest(request: request)
        }
        catch {
            DDLogError("Set directory ID error: \(error.localizedDescription)")
            alertPresenter.errorAlert(title: "Directory ID Error", message: "The request could not be completed, please try again")
        }
        
    }

}
