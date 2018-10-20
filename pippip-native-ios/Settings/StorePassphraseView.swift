//
//  StorePassphraseView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import LocalAuthentication

class StorePassphraseView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var passphraseTextField: UITextField!
    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var settingsViewController: SettingsTableViewController?
    var accountName: String!
    var cell: LocalAuthCell?
    var alertPresenter = AlertPresenter()
    var authPrompt = ""
    var dismissed = false
    var config = Configurator()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {

        Bundle.main.loadNibNamed("StorePassphraseView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        titleLabel.backgroundColor = PippipTheme.lightBarColor
        titleLabel.textColor = PippipTheme.titleColor
        let lockImageView = UIImageView(image: UIImage(named: "passphrase"))
        passphraseTextField.rightView = lockImageView
        passphraseTextField.rightViewMode = .always
        storeButton.backgroundColor = PippipTheme.buttonColor
        storeButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        cancelButton.backgroundColor = PippipTheme.cancelButtonColor
        cancelButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)
        
        let laContext = LAContext()
        var authError: NSError?
        if (laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError)) {
            authPrompt = ""
            switch laContext.biometryType {
            case .none:
                print("Local authentication not supported")
                break
            case .touchID:
                authPrompt = "Please provide your thumbprint to open Pippip"
                break
            case .faceID:
                authPrompt = "Please use face ID to open Pippip"
                break
            }
        }

    }

    func dismiss() {

        if !dismissed {
            DispatchQueue.main.async {
                guard let initialState = self.cell?.initialState else { return }
                self.config.useLocalAuth = initialState
                self.cell?.localAuthSwitch.setOn(initialState, animated: true)
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.center.y = 0.0
                self.alpha = 0.0
                self.settingsViewController?.blurView.alpha = 0.0
            }, completion: { completed in
                self.dismissed = true
                self.removeFromSuperview()
            })
        }
        
    }
    
    @IBAction func storeTapped(_ sender: Any) {
        
        let passphrase = passphraseTextField.text!
        let keychain = Keychain(service: Keychain.PIPPIP_TOKEN_SERVICE)
        DispatchQueue.global().async {
            do {
                if try UserVault.validatePassphrase(accountName: self.accountName, passphrase: passphrase) {
                    do {
                        try keychain.accessibility(protection: .passcodeSetThisDeviceOnly, createFlag: .userPresence)
                                    .authenticationPrompt(self.authPrompt)
                                    .set(passphrase: passphrase, key: self.config.uuid)
                        self.config.useLocalAuth = true
                        self.cell?.initialState = true
                    }
                    catch {
                        print("Error storing passphrase in keychain: \(error.localizedDescription)")
                        self.config.useLocalAuth = false
                        self.alertPresenter.errorAlert(title: "Store Passphrase Error",
                                                       message: "The passphrase could not be stored in the keychain")
                        DispatchQueue.main.async {
                            self.cell?.localAuthSwitch.setOn(false, animated: true)
                        }
                    }
                }
            }
            catch {
                self.alertPresenter.errorAlert(title: "Invalid Passphrase",
                                               message: "Please provide the passphrase that is used to sign in")
                DispatchQueue.main.async {
                    self.config.useLocalAuth = false
                    self.cell?.localAuthSwitch.setOn(false, animated: true)
                }
            }
        }

        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.settingsViewController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.dismissed = true
            self.removeFromSuperview()
        })

    }

    @IBAction func cancelTapped(_ sender: Any) {

        DispatchQueue.main.async {
            guard let initialState = self.cell?.initialState else { return }
            self.config.useLocalAuth = initialState
            self.cell?.localAuthSwitch.setOn(initialState, animated: true)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.settingsViewController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.removeFromSuperview()
        })
        
    }
    
}
