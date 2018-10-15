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

class AuthView: UIView, ControllerBlurProtocol {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var secommLabel: UILabel!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var authButtonLeading: NSLayoutConstraint!
    @IBOutlet weak var authButtonTrailing: NSLayoutConstraint!
    @IBOutlet weak var quickstartButton: UIButton!
    
    var blurController: ControllerBlurProtocol?
    var localAuthenticator: LocalAuthenticator!
    var config = Configurator()
    var signInView: SignInView?
    var newAccountView: NewAccountView?
    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
    var navigationController: UINavigationController?   // This is to satisfy the protocol. DO NOT USE!
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(passphraseReady(_:)),
                                               name: Notifications.PassphraseReady, object: nil)
    
    }

    func authenticationFailed(reason: String) {
        
        MBProgressHUD.hide(for: self, animated: true)
        enableAuthentication()

    }
    
    func enableAuthentication() {
        
        assert(Thread.isMainThread)
        if AccountSession.instance.accountLoaded {
            if !AccountSession.instance.loggedOut && config.useLocalAuth {
                localAuthenticator.getKeychainPassphrase(uuid: config.uuid)
            }
            else {
                self.authButton.setTitle("Sign In", for: .normal)
                let screenWidth = self.bounds.width
                let abWidth = screenWidth * PippipGeometry.signInButtonWidthRatio
                let abConstraint = (screenWidth - abWidth) / 2
                authButtonLeading.constant = abConstraint
                authButtonTrailing.constant = abConstraint
                authButton.isHidden = false
            }
        }
        else {
            authButton.setTitle("Create A New Account", for: .normal)
            let screenWidth = self.bounds.width
            let abWidth = screenWidth * PippipGeometry.newAccountButtonWidthRatio
            let abConstraint = (screenWidth - abWidth) / 2
            authButtonLeading.constant = abConstraint
            authButtonTrailing.constant = abConstraint
            authButton.isHidden = false
        }

    }
    
    func dismiss(completion: @escaping (Bool) -> Void) {
        
        assert(Thread.isMainThread)
        NotificationCenter.default.removeObserver(self, name: Notifications.UpdateProgress, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.PresentAlert, object: nil)
        DispatchQueue.main.async {
            self.authButton.isHidden = true
            UIView.animate(withDuration: 0.3, animations: {
                self.center.y = 0.0
                self.alpha = 0.0
                self.blurController?.blurView.alpha = 0.0
            }, completion: { (completed) in
                MBProgressHUD.hide(for: self, animated: true)
                completion(completed)
            })
        }
        
    }

    func doAuthenticate(passphrase: String) {

        assert(Thread.isMainThread)
        authButton.isHidden = true
        if !AccountSession.instance.serverAuthenticated && !AccountSession.instance.loggedOut {
            NotificationCenter.default.addObserver(self, selector: #selector(updateProgress(_:)),
                                                   name: Notifications.UpdateProgress, object: nil)
            //NotificationCenter.default.addObserver(self, selector: #selector(presentAlert(_:)),
            //                                       name: Notifications.PresentAlert, object: nil)
            let hud = MBProgressHUD.showAdded(to: self, animated: true)
            hud.mode = .annularDeterminate;
            hud.contentColor = PippipTheme.buttonColor
            hud.label.textColor = UIColor.flatTealDark
            hud.label.text = "Authenticating...";
        }
        localAuthenticator.doAuthenticate(passphrase: passphrase)

    }
    
    func doNewAccount(accountName: String, passphrase: String, enableBiometrics: Bool) {
        
        assert(Thread.isMainThread)
        authButton.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateProgress(_:)),
                                               name: Notifications.UpdateProgress, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(self.presentAlert(_:)),
        //                                       name: Notifications.PresentAlert, object: nil)
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.mode = .annularDeterminate;
        hud.contentColor = PippipTheme.buttonColor
        hud.label.textColor = UIColor.flatTealDark
        hud.label.text = "Creating...";
        localAuthenticator.doNewAccount(accountName: accountName, passphrase: passphrase, biometricsEnabled: enableBiometrics)
        
    }
    
    func present(completion: @escaping (Bool) -> Void) {
        
        assert(Thread.isMainThread)
        UIView.animate(withDuration: 0.3, animations: {
            self.center = self.superview!.center
            self.alpha = 1.0
            self.blurController?.blurView.alpha = 0.6
        }, completion: { (completed) in
            completion(completed)
        })
        
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
        newAccountView?.createCompletion = doNewAccount(accountName:passphrase:enableBiometrics:)
        
        addSubview(self.newAccountView!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView.alpha = 0.3
            self.newAccountView?.alpha = 1.0
        }, completion: { complete in
            self.newAccountView?.accountNameTextField.becomeFirstResponder()
        })
        
    }
    
    func showSignInView(accountName: String) {
        
        let frame = self.bounds
        let viewRect = CGRect(x: 0.0, y: 0.0,
                              width: frame.width * PippipGeometry.signInViewWidthRatio,
                              height: frame.height * PippipGeometry.signInViewHeightRatio)
        signInView = SignInView(frame: viewRect)
        let viewCenter = CGPoint(x: self.center.x, y: self.center.y - PippipGeometry.signInViewOffset)
        signInView?.center = viewCenter
        signInView?.alpha = 0.3
        
        signInView?.accountName = accountName
        signInView?.blurController = self
        signInView?.signInCompletion = doAuthenticate(passphrase:)
        
        addSubview(signInView!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView.alpha = 0.6
            self.signInView?.alpha = 1.0
        }, completion: { complete in
            self.signInView?.passphraseTextField.becomeFirstResponder()
        })
        
    }
    
  @objc func passphraseReady(_ notification: Notification) {
        
        DispatchQueue.main.async {
            if let passphrase = notification.object as! String? {
                self.doAuthenticate(passphrase: passphrase)
            }
            else {
                self.authButton.setTitle("Sign In", for: .normal)
                let screenWidth = self.bounds.width
                let abWidth = screenWidth * PippipGeometry.signInButtonWidthRatio
                let abConstraint = (screenWidth - abWidth) / 2
                self.authButtonLeading.constant = abConstraint
                self.authButtonTrailing.constant = abConstraint
                self.authButton.isHidden = false
            }
        }
        
    }
    

    @IBAction func quickstartPressed(_ sender: Any) {

        UIView.animate(withDuration: 0.3, animations: {
            self.slideshow.alpha = 1.0
        }, completion: nil)
        
    }

    @IBAction func authPressed(_ sender: Any) {
    
        if AccountSession.instance.accountLoaded {
            showSignInView(accountName: AccountSession.instance.accountName)
        }
        else {
            showNewAccountView()
        }

    }
    
    @objc func didTap() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.slideshow.alpha = 0.0
        }, completion: nil)
        
    }

    // Notifications

    @objc func updateProgress(_ notification: Notification) {
        
        let userInfo = notification.userInfo!
        let p = userInfo[AnyHashable("progress")] as! NSNumber
        DispatchQueue.main.async {
            MBProgressHUD(for: self)?.progress = p.floatValue
        }
        
    }


}
