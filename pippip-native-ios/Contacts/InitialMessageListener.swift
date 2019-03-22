//
//  InitialMessageListener.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/18/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import UIKit

class InitialMessageListener {
    
    var viewController: UIViewController
    var initialMessageView: InitialMessageView?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func listening(_ listen: Bool) {
        
        if listen {
            NotificationCenter.default.addObserver(self, selector: #selector(initialMessages(_:)),
                                                   name: Notifications.InitialMessages, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: Notifications.InitialMessages, object: nil)
        }
    
    }

    func presentView() {
        
        if ContactsModel.instance.initialMessageRequests.count > 0 {
            DispatchQueue.main.async {
                self.showInitialMessageView()
            }
        }

    }

    func showInitialMessageView() {
        
        let frame = viewController.view.bounds
        let viewRect = CGRect(x: 0.0, y: 0.0,
                              width: frame.width * 0.8, height: 206.0)
        initialMessageView = InitialMessageView(frame: viewRect)
        initialMessageView?.setRequest(ContactsModel.instance.initialMessageRequests[0])
        initialMessageView!.alpha = 0.0
        initialMessageView!.center = viewController.view.center
        
        viewController.view.addSubview(initialMessageView!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.initialMessageView!.alpha = 1.0
        }, completion: nil)
        

    }
    
    // Notification
    @objc func initialMessages(_ notification: Notification) {
        
        DispatchQueue.main.async {
            self.showInitialMessageView()
        }
        
    }

}
