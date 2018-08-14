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
        changePassphraseButton.backgroundColor = PippipTheme.buttonColor
        changePassphraseButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        cancelButton.backgroundColor = PippipTheme.cancelButtonColor
        cancelButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)
        
    }
    
    @IBAction func changePassphraseTapped(_ sender: Any) {
        
        let oldPassphrase = oldPassphraseTextView.text ?? ""
        let newPassphrase = newPassphraseTextView.text ?? ""
        do {
            if newPassphrase.utf8.count == 0 {
                settingsViewController?.showEmptyPassphraseWarning(oldPassphrase: oldPassphrase,
                                                                   newPassphrase: newPassphrase)
            }
            else if try UserVault.validatePassphrase(oldPassphrase) {
                settingsViewController?.changePassphrase(oldPassphrase: oldPassphrase,
                                                         newPassphrase: newPassphrase)
            }
        }
        catch {
            alertPresenter.infoAlert(title: "Invalid Old Passphrase",
                                     message: "The old passphrase you entered is invalid, passphrase not changed")
        }

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

}
