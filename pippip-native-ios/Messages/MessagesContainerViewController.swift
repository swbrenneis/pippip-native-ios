//
//  ContainerViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/12/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import UIKit

enum ViewMode {
    case preview
    case compose
}

class MessagesContainerViewController: UIViewController {

    @IBOutlet weak var controllerContainer: UIView!

    var viewMode: ViewMode = .preview {
        didSet{
            setController()
        }
    }
    var alertPresenter = AlertPresenter()
    var decorator: MessagesContainerDecorator?
    var currentController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        alertPresenter.present = true

        setController()

    }

    func setController() {
        
        switch viewMode {
        case .compose:
            guard let controller = decorator?.composeController else { return }
            controller.willMove(toParent: self)
            currentController?.view.removeFromSuperview()
            controllerContainer.addSubview(controller.view)
            addChild(controller)
            controller.didMove(toParent: self)
            currentController = controller
        case .preview:
            guard let controller = decorator?.previewController else { return }
            controller.willMove(toParent: self)
            currentController?.view.removeFromSuperview()
            controllerContainer.addSubview(controller.view)
            addChild(controller)
            controller.didMove(toParent: self)
            currentController = controller
        }
        
    }
    
}
