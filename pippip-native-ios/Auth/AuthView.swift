//
//  AuthView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/17/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import PMAlertController
import ChameleonFramework

class AuthView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var logoTrailing: NSLayoutConstraint!
    @IBOutlet weak var logoLeading: NSLayoutConstraint!
    @IBOutlet weak var logoTop: NSLayoutConstraint!
    @IBOutlet weak var secommLabel: UILabel!
    
    var accountName = AccountSession.accountName
    var viewController: UIViewController!
    var authenticator = Authenticator()
    var newAccountCreator = NewAccountCreator()
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

        Bundle.main.loadNibNamed("AuthView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

    }

    @IBAction func authSelected(_ sender: Any) {
        
        let alert = PMAlertController(title: accountName!,
                                      description: "Enter your passphrase",
                                      image: nil,
                                      style: PMAlertControllerStyle.alert)
        alert.addTextField({ (textField) in
            textField?.placeholder = "Passphrase"
            textField?.autocorrectionType = .no
            textField?.spellCheckingType = .no
            textField?.autocapitalizationType = .none
            textField?.becomeFirstResponder()
            //textField?.returnKeyType = .go
            //textField?.delegate = self
        })
        alert.addAction(PMAlertAction(title: "Sign In",
                                      style: .default, action: { () in
                                        let passphrase = alert.textFields[0].text ?? ""
                                        self.doAuthenticate(passphrase)
        }))
        alert.addAction(PMAlertAction(title: "Cancel", style: .cancel))
        viewController.present(alert, animated: true, completion: nil)
        
    }

    func doAuthenticate(_ passphrase: String) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.authenticated(_:)),
                                               name: Notifications.Authenticated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateProgress(_:)),
                                               name: Notifications.UpdateProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.presentAlert(_:)),
                                               name: Notifications.PresentAlert, object: nil)
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.mode = .annularDeterminate;
        hud.label.text = "Authenticating...";
        authenticator.authenticate(accountName: self.accountName!, passphrase: passphrase)
        
    }
    
    @objc func authenticated(_ notification: Notification) {
        
        NotificationCenter.default.removeObserver(self, name: Notifications.Authenticated, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.UpdateProgress, object: nil)
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self, animated: true)
            NotificationCenter.default.post(name: Notifications.NewSession, object: nil)
            self.removeFromSuperview()
            self.authButton.setTitle("Sign In", for: .normal)
        }
        
    }

    // This is just used to dismiss the HUD
    @objc func presentAlert(_ notification: Notification) {

        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self, animated: true)
        }
        
    }
    
    @objc func updateProgress(_ notification: Notification) {
        
        let userInfo = notification.userInfo!
        let p = userInfo[AnyHashable("progress")] as! NSNumber
        DispatchQueue.main.async {
            MBProgressHUD(for: self)?.progress = p.floatValue
        }
        
    }

}
