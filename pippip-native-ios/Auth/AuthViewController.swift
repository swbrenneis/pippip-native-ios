//
//  AuthViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework
import PMAlertController

class AuthViewController: UIViewController {

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var logoTrailing: NSLayoutConstraint!
    @IBOutlet weak var logoTop: NSLayoutConstraint!
    @IBOutlet weak var logoLeading: NSLayoutConstraint!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var quickstartButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var secommLabel: UILabel!

    var accountName: String?
    var alertPresenter = AlertPresenter()
    var authenticator = Authenticator()
    var newAccountCreator = NewAccountCreator()

    override func viewDidLoad() {
        super.viewDidLoad()

        PippipTheme.setTheme()
        SecommAPI.initializeAPI()
        
        // Do any additional setup after loading the view.
        let bounds = self.view.bounds
        let logoWidth = bounds.width * 0.7
        logoLeading.constant = (bounds.width - logoWidth) / 2
        logoTrailing.constant = (bounds.width - logoWidth) / 2
        let backgroundColor = UIColor.flatForestGreen.lighten(byPercentage: 0.15)!
        self.view.backgroundColor = backgroundColor
        authButton.setTitleColor(ContrastColorOf(backgroundColor, returnFlat: false), for: .normal)
        authButton.backgroundColor = .clear
        quickstartButton.setTitleColor(ContrastColorOf(backgroundColor, returnFlat: false), for: .normal)
        quickstartButton.backgroundColor = .clear
        versionLabel.textColor = UIColor.flatSand
        secommLabel.textColor = UIColor.flatSand

        do {
            try ApplicationInitializer.accountSession.loadAccount()
        }
        catch {
            print("Error loading account name: \(error)")
        }
        accountName = AccountSession.accountName
        if accountName != nil {
            authButton.setTitle("Sign In", for: .normal)
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        alertPresenter.present = true

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        alertPresenter.present = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        present(alert, animated: true, completion: nil)
        
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
        present(alert, animated: true, completion: nil)
        
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
        present(alert, animated: true, completion: nil)
        
    }
    
    func doAuthenticate(_ passphrase: String) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.authenticated(_:)),
                                               name: Notifications.Authenticated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateProgress(_:)),
                                               name: Notifications.UpdateProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.presentAlert(_:)),
                                               name: Notifications.PresentAlert, object: nil)
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .annularDeterminate;
        hud.label.text = "Authenticating...";
        authenticator.authenticate(accountName: self.accountName!, passphrase: passphrase)
        
    }
    
    func doNewAccount(_ passphrase: String) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.authenticated(_:)),
                                               name: Notifications.Authenticated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateProgress(_:)),
                                               name: Notifications.UpdateProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.presentAlert(_:)),
                                               name: Notifications.PresentAlert, object: nil)
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .annularDeterminate;
        hud.label.text = "Creating...";
        newAccountCreator.createAccount(accountName: self.accountName!, passphrase: passphrase)
        
    }
    
    @IBAction func authSelected(_ sender: Any) {

        if accountName != nil {
            doAuthenticateAlerts()
        }
        else {
            doNewAccountAlerts()
        }

    }

    @objc func authenticated(_ notification: Notification) {
        
        NotificationCenter.default.removeObserver(self, name: Notifications.Authenticated, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.UpdateProgress, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.PresentAlert, object: nil)
        ApplicationInitializer.accountSession.loadConfig()
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            NotificationCenter.default.post(name: Notifications.NewSession, object: nil)
            self.authButton.setTitle("Sign In", for: .normal)
            self.performSegue(withIdentifier: "AuthCompleteSegue", sender: nil)
        }
        
    }
    
    // This is just used to dismiss the HUD
    @objc func presentAlert(_ notification: Notification) {
        
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        
    }
    
    @objc func updateProgress(_ notification: Notification) {
        
        let userInfo = notification.userInfo!
        let p = userInfo[AnyHashable("progress")] as! NSNumber
        DispatchQueue.main.async {
            MBProgressHUD(for: self.view)?.progress = p.floatValue
        }
        
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
