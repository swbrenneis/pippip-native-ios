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
    static var navBarColor: UIColor!
    static var navBarTint: UIColor!
    static var darkCellColor: UIColor!
    static var mediumCellColor: UIColor!
    static var lightCellColor: UIColor!

    static var viewTextColor: UIColor!
    static var buttonDarkTextColor: UIColor!
    static var buttonMediumTextColor: UIColor!
    static var buttonLightTextColor: UIColor!
    static var infoAlertColor = UIColor.flatSand
    static var errorAlertColor = UIColor.flatOrange
    static var successAlertColor = UIColor.flatGreen
    static var darkTextColor: UIColor!
    static var mediumTextColor: UIColor!
    static var lightTextColor: UIColor!

    static var cellCorners: CGFloat = 15.0

    static func setTheme() {

        let colorScheme = ColorSchemeOf(.complementary, color: UIColor.flatCoffee, isFlatScheme: false)
        viewColor = colorScheme[4].lighten(byPercentage: 0.15)!
        navBarColor = viewColor.lighten(byPercentage: 0.1)!
        navBarTint = ContrastColorOf(navBarColor, returnFlat: false)
        darkCellColor = UIColor.flatForestGreen.lighten(byPercentage: 0.1)!
        mediumCellColor = darkCellColor.lighten(byPercentage: 0.1)!
        lightCellColor = darkCellColor.lighten(byPercentage: 0.2)!

        viewTextColor = ContrastColorOf(viewColor, returnFlat: false)
        buttonDarkTextColor = colorScheme[2]
        buttonMediumTextColor = colorScheme[1]
        buttonLightTextColor = colorScheme[0]

        darkTextColor = ContrastColorOf(darkCellColor, returnFlat: true)
        mediumTextColor = ContrastColorOf(mediumCellColor, returnFlat: true)
        lightTextColor = ContrastColorOf(lightCellColor, returnFlat: true)

    }

}
