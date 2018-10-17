//
//  ControllerBlurProtocol.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 8/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

protocol ControllerBlurProtocol {
    
    var blurView: UIVisualEffectView { get set }
    var navigationController: UINavigationController? { get }

}
