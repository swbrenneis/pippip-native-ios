//
//  PassphraseAlertView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 8/9/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class PassphraseAlertView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usePassphraseButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
  
    var newAccountView: NewAccountView?
    var settingsViewController: SettingsTableViewController?
    // Used for the change passphrase function
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
        
        Bundle.main.loadNibNamed("PassphraseAlertView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        titleLabel.textColor = PippipTheme.titleColor
        titleLabel.backgroundColor = PippipTheme.lightBarColor
        usePassphraseButton.backgroundColor = PippipTheme.buttonColor
        usePassphraseButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        cancelButton.backgroundColor = PippipTheme.cancelButtonColor
        cancelButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)

    }

    @IBAction func usePassphraseTapped(_ sender: Any) {

        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
        }, completion: { complete in
            self.removeFromSuperview()
            self.newAccountView?.dismissAndCreate()
            self.settingsViewController?.changePassphrase(oldPassphrase: self.oldPassphrase,
                                                          newPassphrase: self.newPassphrase)
        })
        
    }

    @IBAction func cancelTapped(_ sender: Any) {

        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
        }, completion: { complete in
            self.removeFromSuperview()
        })

    }

}
