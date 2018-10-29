//
//  VerifyPassphraseView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 8/12/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class VerifyPassphraseView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var passphraseTextField: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    var settingsViewController: SettingsTableViewController?
    var alertPresenter = AlertPresenter()
    var accountName: String!
    
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
        let accountDeleter = AccountDeleter()
        do {
            if try UserVault.validatePassphrase(accountName: accountName, passphrase: passphrase) {
                try accountDeleter.deleteAccount()
                self.alertPresenter.infoAlert(message: "This account has been deleted")
                AsyncNotifier.notify(name: Notifications.AccountDeleted)
            }
            else {
                self.alertPresenter.errorAlert(title: "Invalid Passphrase",
                                              message: "Invalid passphrase, account not deleted")
            }
        }
        catch {
            print("Error while deleting account: \(error)")
        }

    }

    func dismiss() {

        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.settingsViewController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.removeFromSuperview()
        })
        
    }
    
    @IBAction func verifyTapped(_ sender: Any) {

        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.settingsViewController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.removeFromSuperview()
            self.verifyandDelete()
        })

    }
    
    @IBAction func cancelButton(_ sender: Any) {

        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.settingsViewController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.removeFromSuperview()
        })
        
    }

}
