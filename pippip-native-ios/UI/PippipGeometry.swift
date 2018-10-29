//
//  PippipGeometry.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import DeviceKit

class PippipGeometry: NSObject {

    static var newAccountButtonWidthRatio: CGFloat!
    static var newAccountViewHeightRatio: CGFloat!
    static var newAccountViewWidthRatio: CGFloat!
    static var newAccountViewOffset: CGFloat!
    static var signInButtonWidthRatio: CGFloat!
    static var signInViewHeightRatio: CGFloat!
    static var signInViewWidthRatio: CGFloat!
    static var signInViewOffset: CGFloat!
    static var verifyPassphraseViewHeightRatio: CGFloat!
    static var verifyPassphraseViewWidthRatio: CGFloat!
    static var verifyPassphraseViewOffset: CGFloat!
    static var storePassphraseViewHeightRatio: CGFloat!
    static var storePassphraseViewWidthRatio: CGFloat!
    static var storePassphraseViewOffset: CGFloat!
    static var changePassphraseViewHeightRatio: CGFloat!
    static var changePassphraseViewWidthRatio: CGFloat!
    static var changePassphraseViewOffset: CGFloat!
    static var changePassphraseViewHideNavBar: Bool!
    static var deleteAccountViewHeightRatio: CGFloat!
    static var deleteAccountViewWidthRatio: CGFloat!
    static var deleteAccountViewOffset: CGFloat!
    static var addToWhitelistViewWidthRatio: CGFloat!
    static var addToWhitelistViewHeightRatio: CGFloat!
    static var addToWhitelistViewOffset: CGFloat!
    static var addContactViewWidthRatio: CGFloat!
    static var addContactViewHeightRatio: CGFloat!
    static var addContactViewOffset: CGFloat!
    static var addContactViewHideNavBar: Bool!
    static var contactDetailViewWidthRatio: CGFloat!
    static var contactDetailViewHeightRatio: CGFloat!
    static var contactDetailViewNoRetryRatio: CGFloat!
    static var contactDetailViewOffset: CGFloat!
    static var ackRequestViewWidthRatio: CGFloat!
    static var ackRequestViewHeightRatio: CGFloat!
    static var ackRequestViewOffset: CGFloat!
    static var contactRequestsViewWidthRatio: CGFloat!
    static var contactRequestsViewHeightRatio: CGFloat!

    static func setGeometry() {

        let device = Device()
        switch device {
        case .iPhone5s, .iPhoneSE:
            set4InchGeomtery()
            break
        case .iPhone6, .iPhone6s, .iPhone7, .iPhone8:
            set4_7InchGeometry()
            break
        case .iPhone6Plus, .iPhone6sPlus, .iPhone7Plus, .iPhone8Plus:
            set5_5InchGeometry()
            break
        case .iPhoneX, .iPhoneXs:
            set5_8InchGeometry()
            break
        case .iPhoneXr:
            set6_1InchGeometry()
            break
        case .iPhoneXsMax:
            set6_5InchGeometry()
            break
        case .iPad2:
            set6_5InchGeometry()
            break
        case .iPad3:
            set6_5InchGeometry()
            break
        case .iPad4:
            set6_5InchGeometry()
            break
        case .iPad5:
            set6_5InchGeometry()
            break
        case .iPad6:
            set6_5InchGeometry()
            break
        case .iPadAir:
            set6_5InchGeometry()
            break
        case .iPadAir2:
            set6_5InchGeometry()
            break
        case .iPadMini:
            set6_5InchGeometry()
            break
        case .iPadMini2:
            set6_5InchGeometry()
            break
        case .iPadMini3:
            set6_5InchGeometry()
            break
        case .iPadMini4:
            set6_5InchGeometry()
            break
        case .iPadPro9Inch:
            set6_5InchGeometry()
            break
        case .iPadPro10Inch:
            set6_5InchGeometry()
            break
        case .iPadPro12Inch:
            set6_5InchGeometry()
            break
        case .iPadPro12Inch2:
            set6_5InchGeometry()
            break
        default:
            setSimulatorGeometry()
            break
        }
    }

    static func set4InchGeomtery() {
        
        newAccountButtonWidthRatio = 0.7
        newAccountViewWidthRatio = 0.8
        newAccountViewHeightRatio = 0.7
        newAccountViewOffset = 0.0
        signInButtonWidthRatio = 0.4
        signInViewWidthRatio = 0.8
        signInViewHeightRatio = 0.55
        signInViewOffset = 90.0
        verifyPassphraseViewWidthRatio = 0.8
        verifyPassphraseViewHeightRatio = 0.5
        verifyPassphraseViewOffset = 30.0
        storePassphraseViewWidthRatio = 0.8
        storePassphraseViewHeightRatio = 0.5
        storePassphraseViewOffset = 30.0
        changePassphraseViewWidthRatio = 0.8
        changePassphraseViewHeightRatio = 0.6
        changePassphraseViewOffset = 10.0
        changePassphraseViewHideNavBar = true
        deleteAccountViewWidthRatio = 0.8
        deleteAccountViewHeightRatio = 0.4
        deleteAccountViewOffset = 30.0
        addToWhitelistViewWidthRatio = 0.8
        addToWhitelistViewHeightRatio = 0.6
        addToWhitelistViewOffset = 60.0
        addContactViewWidthRatio = 0.8
        addContactViewHeightRatio = 0.6
        addContactViewOffset = 90.0
        addContactViewHideNavBar = true
        contactDetailViewWidthRatio = 0.9
        contactDetailViewHeightRatio = 0.3
        contactDetailViewNoRetryRatio = 0.23
        contactDetailViewOffset = 70.0
        contactRequestsViewWidthRatio = 0.85
        contactRequestsViewHeightRatio = 0.7
        ackRequestViewWidthRatio = 0.9
        ackRequestViewHeightRatio = 0.85

    }
    
    static func set4_7InchGeometry() {
        
        newAccountButtonWidthRatio = 0.7
        newAccountViewWidthRatio = 0.8
        newAccountViewHeightRatio = 0.7
        newAccountViewOffset = 0.0
        signInButtonWidthRatio = 0.4
        signInViewWidthRatio = 0.75
        signInViewHeightRatio = 0.5
        signInViewOffset = 80.0
        verifyPassphraseViewWidthRatio = 0.8
        verifyPassphraseViewHeightRatio = 0.5
        verifyPassphraseViewOffset = 90.0
        storePassphraseViewWidthRatio = 0.8
        storePassphraseViewHeightRatio = 0.5
        storePassphraseViewOffset = 30.0
        changePassphraseViewWidthRatio = 0.8
        changePassphraseViewHeightRatio = 0.55
        changePassphraseViewOffset = 15.0
        changePassphraseViewHideNavBar = false
        deleteAccountViewWidthRatio = 0.7
        deleteAccountViewHeightRatio = 0.4
        deleteAccountViewOffset = 65.0
        addToWhitelistViewWidthRatio = 0.8
        addToWhitelistViewHeightRatio = 0.55
        addToWhitelistViewOffset = 60.0
        addContactViewWidthRatio = 0.8
        addContactViewHeightRatio = 0.55
        addContactViewOffset = 80.0
        addContactViewHideNavBar = false
        contactDetailViewWidthRatio = 0.9
        contactDetailViewHeightRatio = 0.27
        contactDetailViewNoRetryRatio = 0.2
        contactDetailViewOffset = 70.0
        contactRequestsViewWidthRatio = 0.85
        contactRequestsViewHeightRatio = 0.7
        ackRequestViewWidthRatio = 0.9
        ackRequestViewHeightRatio = 0.8

    }
    
    static func set5_5InchGeometry() {
        
        newAccountButtonWidthRatio = 0.6
        newAccountViewWidthRatio = 0.7
        newAccountViewHeightRatio = 0.5
        newAccountViewOffset = 95.0
        signInButtonWidthRatio = 0.4
        signInViewWidthRatio = 0.7
        signInViewHeightRatio = 0.45
        signInViewOffset = 114.0
        verifyPassphraseViewWidthRatio = 0.7
        verifyPassphraseViewHeightRatio = 0.4
        verifyPassphraseViewOffset = 30.0
        storePassphraseViewWidthRatio = 0.7
        storePassphraseViewHeightRatio = 0.4
        storePassphraseViewOffset = 30.0
        changePassphraseViewWidthRatio = 0.7
        changePassphraseViewHeightRatio = 0.44
        changePassphraseViewOffset = 15.0
        changePassphraseViewHideNavBar = false
        deleteAccountViewWidthRatio = 0.7
        deleteAccountViewHeightRatio = 0.3
        deleteAccountViewOffset = 65.0
        addToWhitelistViewWidthRatio = 0.7
        addToWhitelistViewHeightRatio = 0.5
        addToWhitelistViewOffset = 65.0
        addContactViewWidthRatio = 0.8
        addContactViewHeightRatio = 0.55
        addContactViewOffset = 80.0
        addContactViewHideNavBar = false
        contactDetailViewWidthRatio = 0.9
        contactDetailViewHeightRatio = 0.24
        contactDetailViewNoRetryRatio = 0.18
        contactDetailViewOffset = 70.0
        contactRequestsViewWidthRatio = 0.85
        contactRequestsViewHeightRatio = 0.7
        ackRequestViewWidthRatio = 0.9
        ackRequestViewHeightRatio = 0.8

    }
    
    static func set5_8InchGeometry() {
        
        newAccountButtonWidthRatio = 0.7
        newAccountViewWidthRatio = 0.7
        newAccountViewHeightRatio = 0.45
        newAccountViewOffset = 115.0
        signInButtonWidthRatio = 0.4
        signInViewWidthRatio = 0.75
        signInViewHeightRatio = 0.4
        signInViewOffset = 125.0
        verifyPassphraseViewWidthRatio = 0.75
        verifyPassphraseViewHeightRatio = 0.4
        verifyPassphraseViewOffset = 30.0
        storePassphraseViewWidthRatio = 0.75
        storePassphraseViewHeightRatio = 0.4
        storePassphraseViewOffset = 30.0
        changePassphraseViewWidthRatio = 0.75
        changePassphraseViewHeightRatio = 0.44
        changePassphraseViewOffset = 15.0
        changePassphraseViewHideNavBar = false
        deleteAccountViewWidthRatio = 0.75
        deleteAccountViewHeightRatio = 0.3
        deleteAccountViewOffset = 65.0
        addToWhitelistViewWidthRatio = 0.75
        addToWhitelistViewHeightRatio = 0.44
        addToWhitelistViewOffset = 80.0
        addContactViewWidthRatio = 0.77
        addContactViewHeightRatio = 0.47
        addContactViewOffset = 90.0
        addContactViewHideNavBar = false
        contactDetailViewWidthRatio = 0.9
        contactDetailViewHeightRatio = 0.21
        contactDetailViewNoRetryRatio = 0.16
        contactDetailViewOffset = 70.0
        contactRequestsViewWidthRatio = 0.85
        contactRequestsViewHeightRatio = 0.7
        ackRequestViewWidthRatio = 0.9
        ackRequestViewHeightRatio = 0.65

    }
    
    static func set6_1InchGeometry() {
        
        newAccountButtonWidthRatio = 0.65
        newAccountViewWidthRatio = 0.75
        newAccountViewHeightRatio = 0.43
        newAccountViewOffset = 145.0
        signInButtonWidthRatio = 0.4
        signInViewWidthRatio = 0.75
        signInViewHeightRatio = 0.38
        signInViewOffset = 175.0
        verifyPassphraseViewWidthRatio = 0.75
        verifyPassphraseViewHeightRatio = 0.35
        verifyPassphraseViewOffset = 30.0
        storePassphraseViewWidthRatio = 0.75
        storePassphraseViewHeightRatio = 0.35
        storePassphraseViewOffset = 30.0
        changePassphraseViewWidthRatio = 0.75
        changePassphraseViewHeightRatio = 0.42
        changePassphraseViewOffset = 35.0
        changePassphraseViewHideNavBar = false
        deleteAccountViewWidthRatio = 0.75
        deleteAccountViewHeightRatio = 0.3
        deleteAccountViewOffset = 65.0
        addToWhitelistViewWidthRatio = 0.75
        addToWhitelistViewHeightRatio = 0.4
        addToWhitelistViewOffset = 90.0
        addContactViewWidthRatio = 0.77
        addContactViewHeightRatio = 0.42
        addContactViewOffset = 90.0
        addContactViewHideNavBar = false
        contactDetailViewWidthRatio = 0.9
        contactDetailViewHeightRatio = 0.2
        contactDetailViewNoRetryRatio = 0.15
        contactDetailViewOffset = 70.0
        contactRequestsViewWidthRatio = 0.85
        contactRequestsViewHeightRatio = 0.7
        ackRequestViewWidthRatio = 0.9
        ackRequestViewHeightRatio = 0.62

    }
    
    static func set6_5InchGeometry() {
        
        newAccountButtonWidthRatio = 0.65
        newAccountViewWidthRatio = 0.75
        newAccountViewHeightRatio = 0.43
        newAccountViewOffset = 150.0
        signInButtonWidthRatio = 0.4
        signInViewWidthRatio = 0.75
        signInViewHeightRatio = 0.38
        signInViewOffset = 175.0
        verifyPassphraseViewWidthRatio = 0.75
        verifyPassphraseViewHeightRatio = 0.4
        verifyPassphraseViewOffset = 70.0
        storePassphraseViewWidthRatio = 0.75
        storePassphraseViewHeightRatio = 0.4
        storePassphraseViewOffset = 70.0
        changePassphraseViewWidthRatio = 0.75
        changePassphraseViewHeightRatio = 0.42
        changePassphraseViewOffset = 65.0
        changePassphraseViewHideNavBar = false
        deleteAccountViewWidthRatio = 0.75
        deleteAccountViewHeightRatio = 0.3
        deleteAccountViewOffset = 65.0
        addToWhitelistViewWidthRatio = 0.75
        addToWhitelistViewHeightRatio = 0.4
        addToWhitelistViewOffset = 100.0
        addContactViewWidthRatio = 0.77
        addContactViewHeightRatio = 0.42
        addContactViewOffset = 90.0
        addContactViewHideNavBar = false
        contactDetailViewWidthRatio = 0.9
        contactDetailViewHeightRatio = 0.2
        contactDetailViewNoRetryRatio = 0.14
        contactDetailViewOffset = 70.0
        contactRequestsViewWidthRatio = 0.85
        contactRequestsViewHeightRatio = 0.7
        ackRequestViewWidthRatio = 0.9
        ackRequestViewHeightRatio = 0.62

    }
    
    static func setSimulatorGeometry() {
        
        guard let simModel = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] else { return }
        switch simModel {
        case "iPhone8,4", "iPhone6,1", "iPhone6,2":                                             // iPhone 5s, SE
            set4InchGeomtery()
            break
        case "iPhone7,2", "iPhone8,1", "iPhone9,1", "iPhone9,3", "iPhone10,1", "iPhone10,4":    // iPhone 6, 6s, 7, 8
            set4_7InchGeometry()
            break
        case "iPhone7,1", "iPhone8,2", "iPhone9,2", "iPhone9,4", "iPhone10,2", "iPhone10,5":    // iPhone 6Plus, 6sPlus, 7Plus, 8Plus
            set5_5InchGeometry()
            break
        case "iPhone10,3", "iPhone10,6", "iPhone11,2":                                          // iPhone X, Xs
            set5_8InchGeometry()
            break
        case "iPhone11,8":                                                                      // iPhone Xr
            set6_1InchGeometry()
            break
        case "iPhone11,4", "iPhone11,6":                                                        // iPhone XsMax
            set6_5InchGeometry()
            break
        default:
            set6_1InchGeometry()
            break
        }

    }

}
