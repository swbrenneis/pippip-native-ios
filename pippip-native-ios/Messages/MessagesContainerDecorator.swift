//
//  ContainerDecorator.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/12/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import Foundation

class MessagesContainerDecorator {
    
    var containerController: MessagesContainerViewController!
    var composeController: ComposeViewController!
    var previewController: MessagesViewController!
    var initialController: InitialViewController!
    
    var viewMode: ViewMode {
        set {
            containerController.viewMode = newValue
        }
        get {
            return containerController.viewMode
        }
    }
    
    private var contact: Contact?
    var selectedContact: Contact? {
        get {
            return contact
        }
        set {
            contact = newValue
        }
    }

    func setNavBarItems() {
        
        switch viewMode {
        case .preview:
            initialController.setMessagesNavBarItems()
        case .compose:
            initialController.setComposeNavBarItems()
        }

    }

}
