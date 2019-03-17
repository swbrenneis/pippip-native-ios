//
//  DeleteContactObserver.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import CocoaLumberjack

class DeleteContactDelegate: EnclaveDelegate<DeleteContactRequest, DeleteContactResponse> {

    var contactManager = ContactManager()
    var messageManager = MessageManager()
/*
    override init(request: DeleteContactRequest) {
        super.init(request: request)

        requestComplete = self.deleteComplete
        requestError = self.deleteError
        responseError = self.deleteError

    }
*/
    func deleteComplete(response: DeleteContactResponse) {


    }

    func deleteError(_ reason: String) {
    }

}
