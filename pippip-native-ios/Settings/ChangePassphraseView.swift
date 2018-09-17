//
//  ChangePassphraseView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 8/13/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ChangePassphraseView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var oldPassphraseTextView: UITextField!
    @IBOutlet weak var newPassphraseTextView: UITextField!
    @IBOutlet weak var changePassphraseButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var settingsViewController: SettingsTableViewController?
    var alertPresenter = AlertPresenter()
    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
    var oldPassphrase = ""
    var newPassphrase = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("ChangePassphraseView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        titleLabel.backgroundColor = PippipTheme.lightBarColor
        titleLabel.textColor = PippipTheme.titleColor
        changePassphraseButton.backgroundColor = PippipTheme.buttonColor.withAlphaComponent(0.7)
        changePassphraseButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        changePassphraseButton.isEnabled = false
        cancelButton.backgroundColor = PippipTheme.cancelButtonColor
        cancelButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)
        
        let frame = self.bounds
        blurView.frame = frame
        blurView.alpha = 0.0
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurView)

    }
    
    @IBAction func changePassphraseTapped(_ sender: Any) {
        
        oldPassphrase = oldPassphraseTextView.text ?? ""
        newPassphrase = newPassphraseTextView.text ?? ""
        do {
            if try UserVault.validatePassphrase(oldPassphrase) {
                dismiss(changePassphrase: true)
            }
        }
        catch {
            alertPresenter.errorAlert(title: "Invalid Old Passphrase",
                                      message: "The old passphrase you entered is invalid")
            // Dismiss here to make brute force harder
            dismiss(changePassphrase: false)
        }

    }
    
    func dismiss(changePassphrase: Bool) {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.blurView.alpha = 0.0
            self.settingsViewController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.removeFromSuperview()
            if changePassphrase {
                let vault = UserVault()
                do {
                    try vault.changePassphrase(oldPassphrase: self.oldPassphrase, newPassphrase: self.newPassphrase)
                    self.alertPresenter.successAlert(title: "Passphrase Changed", message: "Your local passphrase has been changed")
                }
                catch {
                    self.alertPresenter.errorAlert(title: "Change Passphrase Error", message: "An error has occurred, please try again")
                }
            }
        })
        
    }

    @IBAction func cancelTapped(_ sender: Any) {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.settingsViewController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.removeFromSuperview()
        })
        
    }

    @IBAction func newPassphraseChanged(_ sender: Any) {

        guard let passphrase = newPassphraseTextView.text else {
            changePassphraseButton.isEnabled = false
            changePassphraseButton.backgroundColor = PippipTheme.buttonColor.withAlphaComponent(0.7)
            return
        }
        if passphrase.utf8.count > 0 {
            changePassphraseButton.isEnabled = true
            changePassphraseButton.backgroundColor = PippipTheme.buttonColor
        }
        else {
            changePassphraseButton.isEnabled = false
            changePassphraseButton.backgroundColor = PippipTheme.buttonColor.withAlphaComponent(0.7)
        }

    }
    
}