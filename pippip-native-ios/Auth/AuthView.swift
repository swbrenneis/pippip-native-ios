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

    var accountName = AccountManager.accountName
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

        let accountManager = AccountManager()
        do {
            try accountManager.loadAccount()
        }
        catch {
            print("Error loading account name: \(error)")
        }
        accountName = AccountManager.accountName
        if accountName != nil {
            authButton.setTitle("Sign In", for: .normal)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(accountDeleted(_:)),
                                               name: Notifications.AccountDeleted, object: nil)

    }

    @IBAction func authSelected(_ sender: Any) {

        if accountName != nil {
            doAuthenticateAlerts()
        }
        else {
            doNewAccountAlerts()
        }
    }

    func doAuthenticateAlerts() {
        
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
    
    func doNewAccountAlerts() {
        
        let alert = PMAlertController(title: "Create A New Account",
                                      description: "Enter an account name and passphrase",
                                      image: nil,
                                      style: PMAlertControllerStyle.alert)
        alert.addTextField({ (textField) in
            textField?.placeholder = "Account Name"
            textField?.autocorrectionType = .no
            textField?.spellCheckingType = .no
            textField?.autocapitalizationType = .none
            //textField?.returnKeyType = .go
            //textField?.delegate = self
        })
        alert.addTextField({ (textField) in
            textField?.placeholder = "Passphrase"
            textField?.autocorrectionType = .no
            textField?.spellCheckingType = .no
            textField?.autocapitalizationType = .none
            //textField?.returnKeyType = .go
            //textField?.delegate = self
        })
        alert.addAction(PMAlertAction(title: "Create Account",
                                      style: .default, action: { () in
                                        self.accountName = alert.textFields[0].text ?? ""
                                        let passphrase = alert.textFields[1].text ?? ""
                                        if self.accountName!.utf8.count == 0 {
                                            self.alertPresenter.errorAlert(title: "Invalid Account Name",
                                                                           message: "Empty account names are not permitted")
                                        }
                                        else if passphrase.utf8.count == 0 {
                                            DispatchQueue.main.async {
                                                self.passphraseAlert()
                                            }
                                        }
                                        else {
                                            self.doNewAccount(passphrase)
                                        }
        }))
        alert.addAction(PMAlertAction(title: "Cancel", style: .cancel))
        viewController.present(alert, animated: true, completion: nil)
        
    }
    
    func passphraseAlert() {
        
        let alert = PMAlertController(title: "Check Your Passphrase",
                                      description: "Empty passphrases are not recommended",
                                      image: nil,
                                      style: PMAlertControllerStyle.alert)
        alert.addAction(PMAlertAction(title: "Use Empty Passphrase",
                                      style: .default, action: { () in
                                        self.doNewAccount("")
        }))
        alert.addAction(PMAlertAction(title: "Start Over", style: .cancel,
                                      action: { () in
                                        self.accountName = nil
        }))
        alert.alertActionStackView.axis = .vertical
        viewController.present(alert, animated: true, completion: nil)
        
    }
    
    func doAuthenticate(_ passphrase: String) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.authenticated(_:)),
                                               name: Notifications.Authenticated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateProgress(_:)),
                                               name: Notifications.UpdateProgress, object: nil)
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.mode = .annularDeterminate;
        hud.label.text = "Authenticating...";
        authenticator.authenticate(accountName: self.accountName!, passphrase: passphrase)
        
    }
    
    func doNewAccount(_ passphrase: String) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.authenticated(_:)),
                                               name: Notifications.Authenticated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateProgress(_:)),
                                               name: Notifications.UpdateProgress, object: nil)
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.mode = .annularDeterminate;
        hud.label.text = "Creating...";
        newAccountCreator.createAccount(accountName: self.accountName!, passphrase: passphrase)
        
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

    @objc func accountDeleted(_ notification: Notification) {

        DispatchQueue.main.async {
            self.authButton.setTitle("Create New Account", for: .normal)
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
