//
//  GetMessagesObserver.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import CocoaLumberjack

class GetMessagesDelegate: EnclaveDelegate<GetMessagesRequest, GetMessagesResponse> {

    var contactManager = ContactManager()
    var messageManager = MessageManager()
/*
    override init(request: GetMessagesRequest) {
        super.init(request: request)

        requestComplete = self.getComplete
        requestError = self.getError
        responseError = self.getError

    }
*/
    func getComplete(response: GetMessagesResponse) {


    }

    func getError(_ reason: String) {
    }

}
