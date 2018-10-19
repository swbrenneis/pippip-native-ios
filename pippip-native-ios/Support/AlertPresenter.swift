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
import Toast_Swift

class AlertPresenter: NSObject {

    var view: UIView?
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

    override init() {
        super.init()
    }

    init(view: UIView) {
        self.view = view
        super.init()
    }
    
    @objc func infoAlert(title: String, message: String, toast: Bool = false) {
        
        var info = [AnyHashable: Any]()
        info["title"] = title
        info["message"] = message
        info["color"] = PippipTheme.infoAlertColor
        NotificationCenter.default.post(name: Notifications.PresentAlert, object: toast, userInfo: info)
        
    }
    
    @objc func errorAlert(title: String, message: String, toast: Bool = false) {
        
        var info = [AnyHashable: Any]()
        info["title"] = title
        info["message"] = message
        info["color"] = PippipTheme.errorAlertColor
        NotificationCenter.default.post(name: Notifications.PresentAlert, object: toast, userInfo: info)
        
    }
    
    @objc func successAlert(message: String) {
        
        var info = [AnyHashable: Any]()
        info["message"] = message
        NotificationCenter.default.post(name: Notifications.PresentAlert, object: true, userInfo: info)
        
    }

    @objc func presentAlert(_ notification: Notification) {

        guard let info = notification.userInfo else { return }
        guard let toast = notification.object as? Bool else { return }
        guard let message = info["message"] as? String else { return }
        DispatchQueue.main.async {
            if toast {
                self.view?.makeToast(message, duration: 3.0, position: .top)
            }
            else {
                guard let title = info["title"] as? String else { return }
                guard let alertColor = info["color"] as? UIColor else { return }
                RKDropdownAlert.title(title, message: message, backgroundColor: alertColor,
                                      textColor: ContrastColorOf(alertColor, returnFlat: true),
                                      delegate: nil)
            }
        }
        
    }

}
