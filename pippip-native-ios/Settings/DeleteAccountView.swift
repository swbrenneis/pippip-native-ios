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

    func dismiss(blurViewOff: Bool) {

        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
//            if blurViewOff {
//                self.settingsViewController?.blurView.alpha = 0.0
//            }
        }, completion: { completed in
            self.removeFromSuperview()
        })
        
    }
    
    func showVerifyPassphraseView() {
        
        guard let viewController = settingsViewController else { return }
        let frame = viewController.view.bounds
        let viewRect = CGRect(x: 0.0, y: 0.0,
                              width: frame.width * PippipGeometry.verifyPassphraseViewWidthRatio,
                              height: frame.height * PippipGeometry.verifyPassphraseViewHeightRatio)
        let verifyPassphraseView = VerifyPassphraseView(frame: viewRect)
        verifyPassphraseView.center = CGPoint(x: viewController.view.center.x,
                                              y: viewController.view.center.y - PippipGeometry.verifyPassphraseViewOffset)
        verifyPassphraseView.alpha = 0.0
        settingsViewController?.verifyPassphraseView = verifyPassphraseView
        
        settingsViewController?.view.addSubview(verifyPassphraseView)
        
        UIView.animate(withDuration: 0.3, animations: {
            verifyPassphraseView.alpha = 1.0
            // viewController.blurView.alpha = 0.6      Not needed. Set in DeleteAccountCell
        }, completion: { completed in
            verifyPassphraseView.passphraseTextField.becomeFirstResponder()
        })
        
    }
    
    @IBAction func yesTapped(_ sender: Any) {

        showVerifyPassphraseView()
        dismiss(blurViewOff: false)
        
    }

    @IBAction func noTapped(_ sender: Any) {

        dismiss(blurViewOff: true)
        
    }

}
