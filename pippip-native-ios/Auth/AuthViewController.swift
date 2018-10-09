//
//  AuthViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework
import LocalAuthentication
import ImageSlideshow
import DeviceKit

class AuthViewController: UIViewController, AuthenticationDelegateProtocol, ControllerBlurProtocol {

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var logoTrailing: NSLayoutConstraint!
    @IBOutlet weak var logoTop: NSLayoutConstraint!
    @IBOutlet weak var logoLeading: NSLayoutConstraint!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var authButtonLeading: NSLayoutConstraint!
    @IBOutlet weak var authButtonTrailing: NSLayoutConstraint!
    @IBOutlet weak var quickstartButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var secommLabel: UILabel!
    
    var accountName: String?
    var authView: AuthView!
    var alertPresenter = AlertPresenter()
    var localAuthenticator: LocalAuthenticator!
    var localAuth = true
    var authenticator = Authenticator()
    var newAccountCreator = NewAccountCreator()
    var signInView: SignInView?
    var newAccountView: NewAccountView?
    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
    var config = Configurator()
    var slideshow: ImageSlideshow!
    let slides = [ImageSource(imageString: "quickstart01")!,
                  ImageSource(imageString: "quickstart02")!,
                  ImageSource(imageString: "quickstart03")!,
                  ImageSource(imageString: "quickstart04")!,
                  ImageSource(imageString: "quickstart05")!,
                  ImageSource(imageString: "quickstart06")!,
                  ImageSource(imageString: "quickstart07")!,
                  ImageSource(imageString: "quickstart08")!,
                  ImageSource(imageString: "quickstart09")!,
                  ImageSource(imageString: "quickstart10")!,
                  ImageSource(imageString: "quickstart11")!,
                  ImageSource(imageString: "quickstart12")!,
                  ImageSource(imageString: "quickstart13")!]

    override func viewDidLoad() {
        super.viewDidLoad()

        try! AccountSession.instance.loadAccount()
        /*
         * Do this here if the account gets screwed up during debug
        let deleter = AccountDeleter()
        try! deleter.deleteAccount()
        */
        
        PippipTheme.setTheme()
        PippipGeometry.setGeometry()
        SecommAPI.initializeAPI()

        localAuthenticator = LocalAuthenticator(viewController: self, initial: false)
        authenticator.delegate = self
        newAccountCreator.delegate = self

        // Do any additional setup after loading the view.
        let bounds = self.view.bounds
        let backgroundColor = PippipTheme.splashColor
        self.view.backgroundColor = backgroundColor
        authButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        authButton.backgroundColor = PippipTheme.buttonColor
        quickstartButton.setTitleColor(ContrastColorOf(backgroundColor!, returnFlat: false), for: .normal)
        quickstartButton.backgroundColor = .clear
        quickstartButton.isHidden = false
        versionLabel.textColor = UIColor.flatSand
        secommLabel.textColor = UIColor.flatSand
        blurView.frame = bounds
        blurView.alpha = 0.0
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurView)

        slideshow = ImageSlideshow(frame: bounds)
        slideshow.setImageInputs(slides)
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(AuthViewController.didTap))
        slideshow.addGestureRecognizer(recognizer)
        slideshow.alpha = 0.0
        self.view.addSubview(slideshow)

        authView = AuthView(frame: bounds)
        authView.contentView.backgroundColor = PippipTheme.splashColor
        authView.versionLabel.textColor = UIColor.flatSand
        authView.secommLabel.textColor = UIColor.flatSand
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        alertPresenter.present = true
        accountName = AccountSession.instance.accountName

        NotificationCenter.default.addObserver(self, selector: #selector(passphraseReady(_:)),
                                               name: Notifications.PassphraseReady, object: nil)
        authButton.alpha = 0.0
        if accountName == nil {
            authButton.setTitle("Create A New Account", for: .normal)
            let screenWidth = self.view.bounds.width
            let abWidth = screenWidth * PippipGeometry.newAccountButtonWidthRatio
            let abConstraint = (screenWidth - abWidth) / 2
            authButtonLeading.constant = abConstraint
            authButtonTrailing.constant = abConstraint
            authButton.alpha = 1.0
        }
        else {
            localAuthenticator.getKeychainPassphrase(uuid: config.uuid)
        }
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        alertPresenter.present = false
        NotificationCenter.default.removeObserver(self, name: Notifications.PassphraseReady, object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func quickstartPressed(_ sender: Any) {

        UIView.animate(withDuration: 0.3, animations: {
            self.slideshow.alpha = 1.0
        }, completion: nil)

    }
    
    @objc func passphraseReady(_ notification: Notification) {
        
        DispatchQueue.main.async {
            if let passphrase = notification.object as! String? {
                self.doAuthenticate(passphrase: passphrase)
            }
            else {
                self.authButton.alpha = 1.0
                self.authButton.setTitle("Sign In", for: .normal)
                let screenWidth = self.view.bounds.width
                let abWidth = screenWidth * PippipGeometry.signInButtonWidthRatio
                let abConstraint = (screenWidth - abWidth) / 2
                self.authButtonLeading.constant = abConstraint
                self.authButtonTrailing.constant = abConstraint
            }
        }
        
    }
    
    func showAuthenticateView() {

        let frame = self.view.bounds
        let viewRect = CGRect(x: 0.0, y: 0.0,
                              width: frame.width * PippipGeometry.signInViewWidthRatio,
                              height: frame.height * PippipGeometry.signInViewHeightRatio)
        signInView = SignInView(frame: viewRect)
        let viewCenter = CGPoint(x: self.view.center.x, y: self.view.center.y - PippipGeometry.signInViewOffset)
        signInView?.center = viewCenter
        signInView?.alpha = 0.0

        signInView?.accountName = accountName!
        signInView?.blurController = self
        signInView?.signInCompletion = doAuthenticate(passphrase:)

        self.view.addSubview(self.signInView!)

        UIView.animate(withDuration: 0.3, animations: {
            self.blurView.alpha = 0.3
            self.signInView?.alpha = 1.0
        }, completion: { complete in
            self.signInView?.passphraseTextField.becomeFirstResponder()
        })

    }

    func showNewAccountView() {

        let frame = self.view.bounds
        let viewRect = CGRect(x: 0.0, y: 0.0,
                              width: frame.width * PippipGeometry.newAccountViewWidthRatio,
                              height: frame.height * PippipGeometry.newAccountViewHeightRatio)
        newAccountView = NewAccountView(frame: viewRect)
        let viewCenter = CGPoint(x: self.view.center.x, y: self.view.center.y - PippipGeometry.newAccountViewOffset)
        newAccountView?.center = viewCenter
        newAccountView?.alpha = 0.0
        
        newAccountView?.blurController = self
        newAccountView?.createCompletion = doNewAccount(accountName:passphrase:biometricsEnabled:)
        
        self.view.addSubview(self.newAccountView!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView.alpha = 0.3
            self.newAccountView?.alpha = 1.0
        }, completion: { complete in
            self.newAccountView?.accountNameTextField.becomeFirstResponder()
        })
        
    }

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
        DispatchQueue.main.async {
            self.authButton.alpha = 0.0
        }
        
    }
    
    func doNewAccount(accountName: String, passphrase: String, biometricsEnabled: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateProgress(_:)),
                                               name: Notifications.UpdateProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.presentAlert(_:)),
                                               name: Notifications.PresentAlert, object: nil)
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .annularDeterminate;
        hud.contentColor = PippipTheme.buttonColor
        hud.label.textColor = UIColor.flatTealDark
        hud.label.text = "Creating...";
        newAccountCreator.createAccount(accountName: accountName, passphrase: passphrase, biometricsEnabled: biometricsEnabled)
        
    }
    
    @IBAction func authSelected(_ sender: Any) {

        if accountName != nil {
            showAuthenticateView()
        }
        else {
            showNewAccountView()
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

    @objc func didTap() {

        UIView.animate(withDuration: 0.3, animations: {
            self.slideshow.alpha = 0.0
        }, completion: nil)
        
    }

    // Authentication delegate
    
    func authenticated() {
        
        NotificationCenter.default.removeObserver(self, name: Notifications.UpdateProgress, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.PresentAlert, object: nil)
        NotificationCenter.default.post(name: Notifications.AuthComplete, object: nil)
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            NotificationCenter.default.post(name: Notifications.AuthComplete, object: nil)
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
