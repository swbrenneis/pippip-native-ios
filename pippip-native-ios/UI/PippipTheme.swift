//
//  PippipTheme.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/19/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework

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

    static var darkCellColor: UIColor!
    static var mediumCellColor: UIColor!
    static var lightCellColor: UIColor!

    static var buttonDarkTextColor: UIColor!
    static var buttonMediumTextColor: UIColor!
    static var buttonLightTextColor: UIColor!
    static var infoAlertColor = UIColor.flatSand
    static var errorAlertColor = UIColor.flatOrangeDark
    static var successAlertColor = UIColor.flatMintDark
    static var darkTextColor: UIColor!
    static var mediumTextColor: UIColor!
    static var lightTextColor: UIColor!
    static var textFieldBorderColor: UIColor!

    static var cellCorners: CGFloat = 15.0

    static func setTheme() {

        let colorScheme = ColorSchemeOf(.complementary, color: UIColor.flatCoffee, isFlatScheme: false)
//        splashColor = colorScheme[4].lighten(byPercentage: 0.15)!
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

        darkCellColor = UIColor.flatForestGreen.lighten(byPercentage: 0.1)!
//        mediumCellColor = darkCellColor.lighten(byPercentage: 0.1)!
        mediumCellColor = UIColor.flatWhite
        lightCellColor = darkCellColor.lighten(byPercentage: 0.2)!

        buttonDarkTextColor = colorScheme[2]
        buttonMediumTextColor = colorScheme[4].lighten(byPercentage: 0.15)!.withAlphaComponent(0.7)
        buttonLightTextColor = colorScheme[0]
        textFieldBorderColor = colorScheme[4].lighten(byPercentage: 0.15)!.withAlphaComponent(0.7)

        darkTextColor = ContrastColorOf(darkCellColor, returnFlat: true)
        mediumTextColor = ContrastColorOf(mediumCellColor, returnFlat: true)
        lightTextColor = ContrastColorOf(lightCellColor, returnFlat: true)

    }

}
