//
//  DeleteAccountView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 8/11/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class DeleteAccountView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!

    var settingsViewController: SettingsTableViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("DeleteAccountView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        titleLabel.textColor = PippipTheme.titleColor
        titleLabel.backgroundColor = PippipTheme.lightBarColor
        yesButton.backgroundColor = PippipTheme.buttonColor
        yesButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        noButton.backgroundColor = PippipTheme.cancelButtonColor
        noButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)
        
    }
    
    @IBAction func yesTapped(_ sender: Any) {

        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
        }, completion: { completed in
            self.removeFromSuperview()
            self.settingsViewController?.verifyPassphrase()
        })
        
    }

    @IBAction func noTapped(_ sender: Any) {

        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.settingsViewController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.removeFromSuperview()
        })
        
    }

}
