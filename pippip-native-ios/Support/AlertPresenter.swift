//
//  AlertPresenter.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/19/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import RKDropdownAlert
import ChameleonFramework

class AlertPresenter: NSObject {

    var present: Bool = false {
        didSet {
            if present {
                NotificationCenter.default.addObserver(self, selector: #selector(presentAlert(_:)),
                                                       name: Notifications.PresentAlert, object: nil)
            }
            else {
                NotificationCenter.default.removeObserver(self, name: Notifications.PresentAlert, object: nil)
            }
        }
    }

    @objc func infoAlert(title: String, message: String) {
        
        var info = [AnyHashable: Any]()
        info["title"] = title
        info["message"] = message
        info["color"] = PippipTheme.infoAlertColor
        NotificationCenter.default.post(name: Notifications.PresentAlert, object: nil, userInfo: info)
        
    }
    
    @objc func errorAlert(title: String, message: String) {
        
        var info = [AnyHashable: Any]()
        info["title"] = title
        info["message"] = message
        info["color"] = PippipTheme.errorAlertColor
        NotificationCenter.default.post(name: Notifications.PresentAlert, object: nil, userInfo: info)
        
    }
    
    @objc func successAlert(title: String, message: String) {
        
        var info = [AnyHashable: Any]()
        info["title"] = title
        info["message"] = message
        info["color"] = PippipTheme.successAlertColor
        NotificationCenter.default.post(name: Notifications.PresentAlert, object: nil, userInfo: info)
        
    }

    @objc func presentAlert(_ notification: Notification) {

        guard let info = notification.userInfo else { return }
        guard let title = info["title"] as? String else { return }
        guard let message = info["message"] as? String else { return }
        guard let alertColor = info["color"] as? UIColor else { return }
        DispatchQueue.main.async {
            RKDropdownAlert.title(title, message: message, backgroundColor: alertColor,
                                  textColor: ContrastColorOf(alertColor, returnFlat: true),
                                  delegate: nil)
        }
        
    }

}
