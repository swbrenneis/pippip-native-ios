//
//  PippipTheme.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/19/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework
import Toast_Swift
import DeviceKit

class PippipTheme: NSObject {

    static var viewColor: UIColor!
    static var splashColor: UIColor!
    static var buttonColor: UIColor!
    static var buttonTextColor: UIColor!
    static var cancelButtonColor: UIColor!
    static var cancelButtonTextColor: UIColor!
    static var navBarColor: UIColor!
    static var navBarTint: UIColor!
    static var viewTextColor: UIColor!
    static var lightBarColor: UIColor!
    static var titleColor: UIColor!
    static var selectedCellColor: UIColor!
    static var selectedTextColor: UIColor!
    static var incomingMessageBubbleColor: UIColor!
    static var incomingTextColor: UIColor!
    static var outgoingMessageBubbleColor: UIColor!
    static var outgoingTextColor: UIColor!

    static var darkCellColor: UIColor!
    static var mediumCellColor: UIColor!
    static var lightCellColor: UIColor!

    //static var buttonDarkTextColor: UIColor!
    //static var buttonMediumTextColor: UIColor!
    //static var buttonLightTextColor: UIColor!
    static var infoAlertColor = UIColor.flatSand
    static var errorAlertColor = UIColor.flatOrangeDark
    static var successAlertColor = UIColor.flatMintDark
    static var darkTextColor: UIColor!
    static var mediumTextColor: UIColor!
    static var lightTextColor: UIColor!
    //static var textFieldBorderColor: UIColor!

    static var localAuthType: String!
    static var leadingLAType: String!
    
    static func setTheme() {

        splashColor = UIColor.flatTealDark
        viewColor = UIColor.flatWhite
        viewTextColor = ContrastColorOf(viewColor, returnFlat: false)
        buttonColor = UIColor.flatMintDark.darken(byPercentage: 0.05)
        buttonTextColor = ContrastColorOf(buttonColor, returnFlat: true)
        cancelButtonColor = UIColor.flatTealDark.withAlphaComponent(0.3)
        cancelButtonTextColor = UIColor.flatBlack
        navBarColor = UIColor.flatTealDark
        navBarTint = ContrastColorOf(navBarColor, returnFlat: false)
        lightBarColor = UIColor.flatTealDark.withAlphaComponent(0.25)
        titleColor = UIColor.flatTealDark
        selectedCellColor = buttonColor.withAlphaComponent(0.5)
        selectedTextColor = ContrastColorOf(selectedCellColor, returnFlat: true)
        incomingMessageBubbleColor = UIColor.flatTeal.withAlphaComponent(0.25)
        incomingTextColor = UIColor.flatBlack
        outgoingMessageBubbleColor = UIColor.flatTealDark
        outgoingTextColor = ContrastColorOf(outgoingMessageBubbleColor, returnFlat: true)

        var style = ToastStyle()
        style.backgroundColor = UIColor.flatTealDark
        style.messageColor = ContrastColorOf(style.backgroundColor, returnFlat: true)
        style.activityBackgroundColor = .clear
        style.activityIndicatorColor = UIColor.flatWhite
        ToastManager.shared.style = style

        let device = Device()
        if device.isOneOf([.iPhoneX, .iPhoneXr, .iPhoneXs, .iPhoneXsMax]) {
            localAuthType = "face ID"
            leadingLAType = "Face ID"
        }
        else {
            localAuthType = "touch ID"
            leadingLAType = "Touch ID"
        }

    }

}
