//
//  AuthViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/31/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework
import RKDropdownAlert
import PMAlertController
import LocalAuthentication

@objc class AuthViewController: UIViewController, UITextFieldDelegate, RKDropdownAlertDelegate {

    @IBOutlet weak var authButton: UIButton!

    var accountName: String?
    var accountManager = AccountManager()
    var config = Configurator()
    var authenticator = Authenticator()
    @objc var isAuthenticated = false
    @objc var suspendedTime: Int = 0
    private var localAuth = true

    override func viewDidLoad() {
        super.viewDidLoad()

        authButton.backgroundColor = UIColor.clear

    }

    override func viewWillAppear(_ animated: Bool) {

        if isAuthenticated {
            accountName = AccountManager.accountName()
            localAuth = true
            authButton.setTitle("Sign In", for: .normal)
            authButton.isHidden = true
            if !config.useLocalAuth() || suspendedTime > 1800 {
                localAuth = false
                authenticator.logout()
                authButton.isHidden = false
            }
        }
        else {
            localAuth = false
            if accountName == nil {
                accountManager.loadAccount()
                accountName = AccountManager.accountName()
            }
            if (accountName != nil) {
                authButton.setTitle("Sign In", for: .normal)
            }
            else {
                authButton.setTitle("Create New Account", for: .normal)
            }
        }
        authButton.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(presentAlert(_:)),
                                               name: Notifications.PresentAlert, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: Notifications.PresentAlert, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (localAuth) {
            let laContext = LAContext()
            var authError: NSError? = nil
            if (laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError)) {
                laContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                         localizedReason: "Please provide your thumbprint to open Pippip", reply: { (success : Bool, error : Error? ) -> Void in
                                            if (success) {
                                                DispatchQueue.main.async {
                                                    self.dismiss(animated: true, completion: nil)
                                                }
                                            }
                                            else {
                                                print("Thumbprint authentication failed")
                                                self.authenticator.logout()
                                                self.authButton.isHidden = false
                                            }
                })
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func authClicked(_ sender: Any) {

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
        self.present(alert, animated: true, completion: nil)

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
                                            let alertColor = UIColor.flatSand
                                            RKDropdownAlert.title("Invalid Account Name",
                                                                  message: "Empty account names are not permitted", backgroundColor: alertColor,
                                                                  textColor: ContrastColorOf(alertColor, returnFlat: true),
                                                                  time: 2, delegate: self)
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
        self.present(alert, animated: true, completion: nil)
        
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
        self.present(alert, animated: true, completion: nil)

    }

    func doAuthenticate(_ passphrase: String) {

        NotificationCenter.default.addObserver(self, selector: #selector(self.authenticated(_:)),
                                               name: Notifications.Authenticated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateProgress(_:)),
                                               name: Notifications.UpdateProgress, object: nil)
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .annularDeterminate;
        hud.label.text = "Authenticating...";
        authenticator.authenticate(self.accountName, withPassphrase: passphrase)

    }

    func doNewAccount(_ passphrase: String) {

        NotificationCenter.default.addObserver(self, selector: #selector(self.authenticated(_:)),
                                               name: Notifications.Authenticated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateProgress(_:)),
                                               name: Notifications.UpdateProgress, object: nil)
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .annularDeterminate;
        hud.label.text = "Creating...";
        let newAccountCreator = NewAccountCreator()
        newAccountCreator.createAccount(self.accountName, withPassphrase: passphrase)

    }

    @objc func authenticated(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.Authenticated, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.UpdateProgress, object: nil)
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            NotificationCenter.default.post(name: Notifications.NewSession, object: nil)
            self.dismiss(animated: true, completion: nil)
        }

    }

    @objc func presentAlert(_ notification: Notification) {

        let userInfo = notification.userInfo!
        let title = userInfo["title"] as? String
        let message = userInfo["message"] as? String
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            let alertColor = UIColor.flatSand
            RKDropdownAlert.title(title, message: message, backgroundColor: alertColor,
                                  textColor: ContrastColorOf(alertColor, returnFlat: true),
                                  time: 2, delegate: self)
        }
        
    }

    @objc func updateProgress(_ notification: Notification) {

        let userInfo = notification.userInfo!
        let p = userInfo[AnyHashable("progress")] as! NSNumber
        DispatchQueue.main.async {
            MBProgressHUD(for: self.view)?.progress = p.floatValue
        }

    }

    func dropdownAlertWasTapped(_ alert: RKDropdownAlert!) -> Bool {
        return true
    }
    
    func dropdownAlertWasDismissed() -> Bool {
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
