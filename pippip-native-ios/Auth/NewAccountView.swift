//
//  NewAccountView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 8/9/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import LocalAuthentication

class NewAccountView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var accountNameTextField: UITextField!
    @IBOutlet weak var passphraseTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var enableBiometricsButton: UISwitch!
    @IBOutlet weak var biometricsLabel: UILabel!
    @IBOutlet weak var laStackView: UIStackView!
    
    var blurController: ControllerBlurProtocol?
    var alertPresenter = AlertPresenter()
    var accountName = ""
    var passphrase = ""
    var createCompletion = { (accountName: String, passphrase: String, enableBiometrics: Bool) in }
    var biometricsAvailable = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("NewAccountView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true

        titleLabel.textColor = PippipTheme.titleColor
        titleLabel.backgroundColor = PippipTheme.lightBarColor
        let userImageView = UIImageView(image: UIImage(named: "user"))
        accountNameTextField.rightView = userImageView
        accountNameTextField.rightViewMode = .always
        let lockImageView = UIImageView(image: UIImage(named: "passphrase"))
        passphraseTextField.rightView = lockImageView
        passphraseTextField.rightViewMode = .always
        createAccountButton.backgroundColor = PippipTheme.buttonColor.withAlphaComponent(0.7)
        createAccountButton.isEnabled = false
        createAccountButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        cancelButton.backgroundColor = PippipTheme.cancelButtonColor
        cancelButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)

        let laContext = LAContext()
        var authError: NSError? = nil
        if (laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError)) {
            var laType = ""
            switch laContext.biometryType {
            case .none:
                biometricsAvailable = false
                break
            case .touchID:
                laType = "Enable touch ID"
                break
            case .faceID:
                laType = "Enable face ID"
                break
            }
            if biometricsAvailable {
                biometricsLabel.text = laType
            }
            else {
                laStackView.isHidden = true
            }
        }
        else {
            laStackView.isHidden = true
        }
 
    }
    
    func enableCreateButton() {
        
        if accountName.utf8.count > 0 && passphrase.utf8.count > 0 {
            createAccountButton.backgroundColor = PippipTheme.buttonColor
            createAccountButton.isEnabled = true
        }
        else {
            createAccountButton.backgroundColor = PippipTheme.buttonColor.withAlphaComponent(0.7)
            createAccountButton.isEnabled = false
        }

    }

    @IBAction func createTapped(_ sender: Any) {

        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.blurController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.removeFromSuperview()
            self.createCompletion(self.accountName, self.passphrase, self.enableBiometricsButton.isOn)
        })
        
    }
    
    @IBAction func cancelTapped(_ sender: Any) {

        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.blurController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.removeFromSuperview()
        })
        
    }
    
    @IBAction func accountNameChanged(_ sender: Any) {

        accountName = accountNameTextField.text ?? ""
        enableCreateButton()

    }
    
    @IBAction func passphraseChanged(_ sender: Any) {

        passphrase = passphraseTextField.text ?? ""
        enableCreateButton()
        
    }

}
