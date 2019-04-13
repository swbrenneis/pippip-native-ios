//
//  Reauthenticator.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/10/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import Foundation
import CocoaLumberjack

class Reauthenticator<RequestT: EnclaveRequestProtocol,ResponseT: EnclaveResponseProtocol> : ServerAuthenticator {

    var task: EnclaveTask<RequestT, ResponseT>
    
    init(task: EnclaveTask<RequestT, ResponseT>) {
        self.task = task
        super.init(authView: nil)
    }

    func authenticate() {
        
        SecommAPI.instance.startSession(sessionComplete: { (sessionResponse) in
            self.sessionStarted(sessionResponse: sessionResponse)
        })

    }

    override func authorizedComplete(_ authorized: ClientAuthorized) {
        
        do {
            try authorized.processResponse()
            sessionState.sessionId = authorized.sessionId!
            sessionState.authToken = authorized.authToken!
            AccountSession.instance.authenticated()
            task.resendRequest()
        } catch {
            DDLogError("Client authorization error : \(error.localizedDescription)")
        }
        
    }
    
}
