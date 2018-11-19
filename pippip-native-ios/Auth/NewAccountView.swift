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
    var newAccountCreator: NewAccountCreator?
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
        createAccountButton.backgroundColor = PippipTheme.buttonColor.withAlphaComponent(0.5)
        createAccountButton.isEnabled = false
        createAccountButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        cancelButton.backgroundColor = PippipTheme.cancelButtonColor
        cancelButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)

        let laContext = LAContext()
        var authError: NSError? = nil
        if (laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError)) {
            switch laContext.biometryType {
            case .none:
                biometricsLabel.text = "\(PippipTheme.leadingLAType!) not available"
                biometricsAvailable = false
                break
            case .touchID, .faceID:
                biometricsLabel.text = "Enable \(PippipTheme.localAuthType!)"
                break
            }
        }
        else {
            biometricsLabel.text = "\(PippipTheme.leadingLAType!) not available"
            biometricsAvailable = false
        }
        enableBiometricsButton.isOn = biometricsAvailable
        enableBiometricsButton.isEnabled = biometricsAvailable
 
    }
    
    func enableCreateButton() {
        
        guard let accountName = accountNameTextField.text else { return }
        guard let passphrase = passphraseTextField.text else { return }
        if accountName.utf8.count > 0 && passphrase.utf8.count > 0 {
            createAccountButton.backgroundColor = PippipTheme.buttonColor
            createAccountButton.isEnabled = true
        }
        else {
            createAccountButton.backgroundColor = PippipTheme.buttonColor.withAlphaComponent(0.5)
            createAccountButton.isEnabled = false
        }

    }

    func dismiss() {

        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.blurController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.removeFromSuperview()
        })
        
    }
    
    @IBAction func createTapped(_ sender: Any) {

        guard let accountName = accountNameTextField.text else { return }
        guard let passphrase = passphraseTextField.text else { return }
        if let authView = blurController as? AuthView {
            newAccountCreator = NewAccountCreator(authView: authView)
            authView.creatingAccount()
            newAccountCreator?.createAccount(accountName: accountName, passphrase: passphrase,
                                             biometricsEnabled: enableBiometricsButton.isOn)
        }
        dismiss()
        
    }
    
    @IBAction func cancelTapped(_ sender: Any) {

        dismiss()
        
    }
    
    @IBAction func accountNameChanged(_ sender: Any) {

        enableCreateButton()

    }
    
    @IBAction func passphraseChanged(_ sender: Any) {

        enableCreateButton()
        
    }

}
