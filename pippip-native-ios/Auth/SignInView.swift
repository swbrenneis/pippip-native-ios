//
//  SignInView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 8/9/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import Toast_Swift

class SignInView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var passphraseTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var accountName: String = "" {
        didSet {
            accountNameLabel.text = accountName
        }
    }
    var blurController: ControllerBlurProtocol?
    var signInCompletion = { (passphrase: String) in }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("SignInView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true

        accountNameLabel.backgroundColor = PippipTheme.lightBarColor
        accountNameLabel.textColor = PippipTheme.titleColor
        let lockImageView = UIImageView(image: UIImage(named: "passphrase"))
        passphraseTextField.rightView = lockImageView
        passphraseTextField.rightViewMode = .always
        signInButton.backgroundColor = PippipTheme.buttonColor
        signInButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        cancelButton.backgroundColor = PippipTheme.cancelButtonColor
        cancelButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)

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

    @IBAction func cancelTapped(_ sender: Any) {

        self.superview?.hideToastActivity()
        dismiss()

    }

    @IBAction func signInTapped(_ sender: Any) {

        self.passphraseTextField.resignFirstResponder()
        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.blurController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.removeFromSuperview()
            let passphrase = self.passphraseTextField.text ?? ""
            self.signInCompletion(passphrase)
        })
        
    }
}
