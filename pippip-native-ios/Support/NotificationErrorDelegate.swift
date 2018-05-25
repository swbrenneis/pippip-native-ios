//
//  NotificationErrorDelegate.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/23/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

@objc class NotificationErrorDelegate: NSObject, ErrorDelegate {

    var alertPresenter = AlertPresenter()
    var title: String

    @objc init(title: String) {

        self.title = title

    }

    func getMethodError(_ error: String) {

        alertPresenter.errorAlert(title: title, message: error)
        
    }
    
    func postMethodError(_ error: String) {

        alertPresenter.errorAlert(title: title, message: error)
        
    }

    func responseError(_ error: String) {

        alertPresenter.errorAlert(title: title, message: error)
        
    }
    
    func requestError(_ error: String) {

        alertPresenter.errorAlert(title: title, message: error)
        
    }
    
    func sessionError(_ error: String) {

        alertPresenter.errorAlert(title: title, message: error)
        
    }
    
}
