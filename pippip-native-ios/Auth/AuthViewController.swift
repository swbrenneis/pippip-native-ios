//
//  AuthViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework

class AuthViewController: UIViewController, AuthenticationDelegateProtocol {

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
    var signInView: SignInView?
    var newAccountView: NewAccountView?
    var dimView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        PippipTheme.setTheme()
        SecommAPI.initializeAPI()

        authenticator.delegate = self
        newAccountCreator.delegate = self

        // Do any additional setup after loading the view.
        let bounds = self.view.bounds
        let logoWidth = bounds.width * 0.7
        logoLeading.constant = (bounds.width - logoWidth) / 2
        logoTrailing.constant = (bounds.width - logoWidth) / 2
        let backgroundColor = PippipTheme.splashColor
        self.view.backgroundColor = backgroundColor
        authButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        authButton.backgroundColor = PippipTheme.buttonColor
        quickstartButton.setTitleColor(ContrastColorOf(backgroundColor!, returnFlat: false), for: .normal)
        quickstartButton.backgroundColor = .clear
        quickstartButton.isHidden = false
        versionLabel.textColor = UIColor.flatSand
        secommLabel.textColor = UIColor.flatSand
        dimView = UIView(frame: bounds)
        dimView?.backgroundColor = UIColor.flatBlack
        dimView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        dimView?.alpha = 0.0
        self.view.addSubview(dimView!)

        do {
            try ApplicationInitializer.accountSession.loadAccount()
        }
        catch {
            print("Error loading account name: \(error)")
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        alertPresenter.present = true
        accountName = AccountSession.accountName
        if accountName != nil {
            authButton.setTitle("Sign In", for: .normal)
        }
        else {
            authButton.setTitle("Create A New Account", for: .normal)
        }

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        alertPresenter.present = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func quickstartPressed(_ sender: Any) {

        let url = "https://www.pippip.io"
        guard let link = URL(string: url) else { return }
        UIApplication.shared.open(link, options: [:], completionHandler: nil)

    }
    
    func showAuthenticateView() {

        let frame = self.view.bounds
        let viewRect = CGRect(x: 0.0, y: 0.0, width: frame.width * 0.8, height: frame.height * 0.45)
        signInView = SignInView(frame: viewRect)
        let viewCenter = CGPoint(x: self.view.center.x, y: self.view.center.y - 100)
        signInView?.center = viewCenter
        signInView?.alpha = 0.3

        signInView?.accountName = accountName!
        signInView?.authViewController = self

        self.view.addSubview(self.signInView!)

        UIView.animate(withDuration: 0.3, animations: {
            self.dimView?.alpha = 0.3
            self.signInView?.alpha = 1.0
        }, completion: { complete in
            self.signInView?.passphraseTextField.becomeFirstResponder()
        })

    }
    /*
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
            let lockImageView = UIImageView(image: UIImage(named: "passphrase"))
            textField?.rightView = lockImageView
            textField?.rightViewMode = .always
        })
        alert.addAction(PMAlertAction(title: "Sign In",
                                      style: .default, action: { () in
                                        let passphrase = alert.textFields[0].text ?? ""
                                        self.doAuthenticate(passphrase: passphrase)
        }))
        alert.addAction(PMAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true, completion: nil)
        
    }
*/
    func showNewAccountView() {

        let frame = self.view.bounds
        let viewRect = CGRect(x: 0.0, y: 0.0, width: frame.width * 0.8, height: frame.height * 0.5)
        newAccountView = NewAccountView(frame: viewRect)
        let viewCenter = CGPoint(x: self.view.center.x, y: self.view.center.y - 100)
        newAccountView?.center = viewCenter
        newAccountView?.alpha = 0.3
        
        newAccountView?.authViewController = self
        
        self.view.addSubview(self.newAccountView!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.dimView?.alpha = 0.3
            self.newAccountView?.alpha = 1.0
        }, completion: { complete in
            self.newAccountView?.accountNameTextField.becomeFirstResponder()
        })
        
    }
/*
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
            let userImageView = UIImageView(image: UIImage(named: "user"))
            textField?.rightView = userImageView
            textField?.rightViewMode = .always
        })
        alert.addTextField({ (textField) in
            textField?.placeholder = "Passphrase"
            textField?.autocorrectionType = .no
            textField?.spellCheckingType = .no
            textField?.autocapitalizationType = .none
            let lockImageView = UIImageView(image: UIImage(named: "passphrase"))
            textField?.rightView = lockImageView
            textField?.rightViewMode = .always
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
                                            self.doNewAccount(accountName: self.accountName!, passphrase: passphrase)
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
                                        self.doNewAccount(accountName: self.accountName!, passphrase: "")
        }))
        alert.addAction(PMAlertAction(title: "Start Over", style: .cancel,
                                      action: { () in
                                        self.accountName = nil
        }))
        alert.alertActionStackView.axis = .vertical
        present(alert, animated: true, completion: nil)
        
    }
*/
    func doAuthenticate(passphrase: String) {

        NotificationCenter.default.addObserver(self, selector: #selector(self.updateProgress(_:)),
                                               name: Notifications.UpdateProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.presentAlert(_:)),
                                               name: Notifications.PresentAlert, object: nil)
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .annularDeterminate;
        hud.contentColor = PippipTheme.buttonColor
        hud.label.textColor = UIColor.flatTealDark
        hud.label.text = "Authenticating...";
        authenticator.authenticate(accountName: self.accountName!, passphrase: passphrase)
        
    }
    
    func doNewAccount(accountName: String, passphrase: String) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateProgress(_:)),
                                               name: Notifications.UpdateProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.presentAlert(_:)),
                                               name: Notifications.PresentAlert, object: nil)
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .annularDeterminate;
        hud.contentColor = PippipTheme.buttonColor
        hud.label.textColor = UIColor.flatTealDark
        hud.label.text = "Creating...";
        newAccountCreator.createAccount(accountName: accountName, passphrase: passphrase)
        
    }
    
    @IBAction func authSelected(_ sender: Any) {

        if accountName != nil {
            showAuthenticateView()
            // doAuthenticateAlerts()
        }
        else {
            showNewAccountView()
            //doNewAccountAlerts()
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

    // Authentication delegate
    
    func authenticated() {
        
        NotificationCenter.default.removeObserver(self, name: Notifications.UpdateProgress, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.PresentAlert, object: nil)
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            NotificationCenter.default.post(name: Notifications.NewSession, object: nil)
            self.authButton.setTitle("Sign In", for: .normal)
            self.performSegue(withIdentifier: "AuthCompleteSegue", sender: nil)
        }
        
    }
    
    func authenticationFailed(reason: String) {

        alertPresenter.errorAlert(title: "Authentication Error",
                                  message: "There was an error while signing in: \(reason)")
        
    }
    
    func loggedOut() {
        // Nothing to do.
    }

    // MARK: - Navigation

    @IBAction func unwindToAuthView(sender: UIStoryboardSegue) {

        print("Segue unwound to AuthViewController")

    }

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
