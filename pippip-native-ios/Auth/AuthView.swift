//
//  AuthView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/17/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework
import ImageSlideshow
import Toast_Swift
import LocalAuthentication
import CocoaLumberjack

class AuthView: UIView, ControllerBlurProtocol {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var secommLabel: UILabel!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var authButtonLeading: NSLayoutConstraint!
    @IBOutlet weak var authButtonTrailing: NSLayoutConstraint!
    @IBOutlet weak var quickstartButton: UIButton!
    @IBOutlet weak var contactServerLabel: UILabel!
    
    //var newAccount = false
    var blurController: ControllerBlurProtocol?
    var authenticator: Authenticator?
    var config = Configurator()
    var signInView: SignInView?
    var serverAuthenticator: ServerAuthenticator?
    var newAccountView: NewAccountView?
    var alertPresenter = AlertPresenter()
    var blurView = GestureBlurView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
    var navigationController: UINavigationController?
    var authPrompt: String = ""
    var resumePassphraseInvalid = false
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
        blurView.frame = self.bounds
        blurView.alpha = 0.0
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(blurView)
        let backgroundColor = PippipTheme.splashColor
        contentView.backgroundColor = backgroundColor
        versionLabel.textColor = UIColor.flatSand
        secommLabel.textColor = UIColor.flatSand
        contactServerLabel.textColor = UIColor.flatWhite
        contactServerLabel.isHidden = true
        authButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        authButton.backgroundColor = PippipTheme.buttonColor
        authButton.isHidden = true
        quickstartButton.setTitleColor(ContrastColorOf(backgroundColor!, returnFlat: false), for: .normal)
        quickstartButton.backgroundColor = .clear
        quickstartButton.isHidden = false

        slideshow = ImageSlideshow(frame: bounds)
        slideshow.setImageInputs(slides)
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        slideshow.addGestureRecognizer(recognizer)
        slideshow.alpha = 0.0
        addSubview(slideshow)
        
        let laContext = LAContext()
        var authError: NSError?
        if (laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError)) {
            switch laContext.biometryType {
            case .none:
                DDLogInfo("Local authentication not supported")
                break
            case .touchID:
                authPrompt = "Please provide your thumbprint to open Pippip"
                break
            case .faceID:
                authPrompt = "Please use face ID to open Pippip"
                break
            }
        }

    }

    func accountCreated(success: Bool, _ reason: String?) {
        
        DispatchQueue.main.async {
            self.hideToastActivity()
            self.authButton.isHidden = success
            if let message = reason {
                self.alertPresenter.errorAlert(title: "New Account Error", message: message)
            }
            self.dismiss()
        }

    }

    func authenticated(success: Bool, _ reason: String?) {
        
        NotificationCenter.default.post(name: Notifications.AuthComplete, object: nil)  // For messages view controller
        DispatchQueue.main.async {
            self.hideToastActivity()
            self.authButton.isHidden = success
            if let message = reason {
                self.alertPresenter.errorAlert(title: "Sign In Error", message: message)
            }
            if success {
                self.dismiss()
            }
        }
        
    }
    
    func biometricAuthenticate(local: Bool) {
        
        AccountSession.instance.biometricsRunning = true
        if let passhrase = getKeychainPassphrase(uuid: config.uuid) {
            self.makeToastActivity(.center)
            if local {
                if UserVault.validatePassphrase(passphrase: passhrase) {
                    dismiss()
                }
                else {
                    self.hideToastActivity()
                    authButton.isHidden = false
                }
            }
            else {
                self.contactServerLabel.isHidden = false
                serverAuthenticator = ServerAuthenticator(authView: self)
                serverAuthenticator?.authenticate(passphrase: passhrase)
            }
        }
        AccountSession.instance.biometricsRunning = false

    }
    
   func creatingAccount() {

        assert(Thread.isMainThread)
        authButton.isHidden = true
        contactServerLabel.isHidden = false
        self.makeToastActivity(.center)

    }
/*
    func doAuthenticate(passphrase: String) {

        DispatchQueue.main.async {
            self.makeToastActivity(.center)
            self.authButton.isHidden = true
        }
        authenticator?.doAuthenticate(passphrase: passphrase)

    }
    
    func doNewAccount(accountName: String, passphrase: String, enableBiometrics: Bool) {
        
        assert(Thread.isMainThread)
        authButton.isHidden = true
        //newAccount = true
        authenticator?.doNewAccount(accountName: accountName, passphrase: passphrase, biometricsEnabled: enableBiometrics)
        
    }
*/
    func dismiss() {

        assert(Thread.isMainThread)
        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.blurController?.blurView.alpha = 0.0
        }, completion: { (completed) in
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.contactServerLabel.isHidden = true
        })
        
    }

    private func getKeychainPassphrase(uuid: String) -> String? {
        
        let keychain = Keychain(service: Keychain.PIPPIP_TOKEN_SERVICE)
        var passphrase: String?
        do {
            passphrase = try keychain.authenticationPrompt(self.authPrompt).get(key: uuid)
        }
        catch {
            DDLogError("Error retrieving keychain passphrase: \(error.localizedDescription)")
        }
        return passphrase
        
    }
    
    func setNewAccount() {

        authButton.setTitle("Create A New Account", for: .normal)
        let screenWidth = self.bounds.width
        let abWidth = screenWidth * PippipGeometry.newAccountButtonWidthRatio
        let abConstraint = (screenWidth - abWidth) / 2
        authButtonLeading.constant = abConstraint
        authButtonTrailing.constant = abConstraint
        authButton.isHidden = false

    }

    func setSignIn() {
        
        authButton.setTitle("Sign In", for: .normal)
        let screenWidth = self.bounds.width
        let abWidth = screenWidth * PippipGeometry.signInButtonWidthRatio
        let abConstraint = (screenWidth - abWidth) / 2
        authButtonLeading.constant = abConstraint
        authButtonTrailing.constant = abConstraint
        authButton.isHidden = config.useLocalAuth
        
    }
    
    func showNewAccountView() {
        
        let frame = self.bounds
        let viewRect = CGRect(x: 0.0, y: 0.0,
                              width: frame.width * PippipGeometry.newAccountViewWidthRatio,
                              height: frame.height * PippipGeometry.newAccountViewHeightRatio)
        newAccountView = NewAccountView(frame: viewRect)
        let viewCenter = CGPoint(x: self.center.x, y: self.center.y - PippipGeometry.newAccountViewOffset)
        newAccountView?.center = viewCenter
        newAccountView?.alpha = 0.0
        
        newAccountView?.blurController = self
        
        addSubview(self.newAccountView!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView.alpha = 0.3
            self.newAccountView?.alpha = 1.0
        }, completion: { completed in
            self.newAccountView?.accountNameTextField.becomeFirstResponder()
        })
        
    }

    func showSignInView(local: Bool) {
        
        let frame = self.bounds
        let viewRect = CGRect(x: 0.0, y: 0.0,
                              width: frame.width * PippipGeometry.signInViewWidthRatio,
                              height: frame.height * PippipGeometry.signInViewHeightRatio)
        signInView = SignInView(frame: viewRect)
        let viewCenter = CGPoint(x: self.center.x, y: self.center.y - PippipGeometry.signInViewOffset)
        signInView?.center = viewCenter
        signInView?.alpha = 0.3
        signInView?.blurController = self
        signInView?.authView = self
        signInView?.local = local
        addSubview(signInView!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView.alpha = 0.6
            self.signInView?.alpha = 1.0
        }, completion: { completed in
            self.signInView?.passphraseTextField.becomeFirstResponder()
        })
        
    }

    func signingIn() {
        
        authButton.isHidden = true
        contactServerLabel.isHidden = false
        self.makeToastActivity(.center)

    }
    
    @IBAction func quickstartPressed(_ sender: Any) {

        UIView.animate(withDuration: 0.3, animations: {
            self.slideshow.alpha = 1.0
        }, completion: nil)
        
    }

    @IBAction func authPressed(_ sender: Any) {

        if AccountSession.instance.newAccount {
            showNewAccountView()
        }
        else {
            showSignInView(local: resumePassphraseInvalid)
        }

    }
    
    @objc func didTap() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.slideshow.alpha = 0.0
        }, completion: nil)
        
    }

    // Notifications

}
