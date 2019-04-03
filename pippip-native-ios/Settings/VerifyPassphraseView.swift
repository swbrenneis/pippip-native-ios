//
//  VerifyPassphraseView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 8/12/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import CocoaLumberjack

class VerifyPassphraseView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var passphraseTextField: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    var alertPresenter = AlertPresenter()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("VerifyPassphraseView", owner: self, options: nil)
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
        verifyButton.backgroundColor = PippipTheme.buttonColor
        verifyButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        cancelButton.backgroundColor = PippipTheme.cancelButtonColor
        cancelButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)
        
    }

    func verifyandDelete() {
        
        let passphrase = passphraseTextField.text ?? ""
        if UserVault.validatePassphrase(passphrase: passphrase) {
            let accountDeleter = AccountDeleter()
            accountDeleter.deleteAccount()
            AccountSession.instance.accountDeleted()
            dismiss()
            AccountSession.initialViewController?.accountDeleted()
        }
        else {
            self.alertPresenter.errorAlert(title: "Invalid Passphrase",
                                           message: "Invalid passphrase, account not deleted")
        }
        
    }
    
    func dismiss() {

        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
//            self.initialViewController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.removeFromSuperview()
        })
        
    }
    
    @IBAction func verifyTapped(_ sender: Any) {

        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
//            self.settingsViewController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.removeFromSuperview()
            self.verifyandDelete()
        })

    }
    
    @IBAction func cancelButton(_ sender: Any) {

            dismiss()
        
    }

}
