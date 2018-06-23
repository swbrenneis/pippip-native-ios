//
//  QSAuthViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework

class QSAuthViewController: UIViewController {

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var logoTrailing: NSLayoutConstraint!
    @IBOutlet weak var logoLeading: NSLayoutConstraint!
    @IBOutlet weak var newAccountButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var alertImage: UIImageView!
    
    var promptView: QSPromptView!
    var guide = "first"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let bounds = self.view.bounds
        let logoWidth = bounds.width * 0.7
        logoLeading.constant = (bounds.width - logoWidth) / 2
        logoTrailing.constant = (bounds.width - logoWidth) / 2
        let backgroundColor = UIColor.flatForestGreen.lighten(byPercentage: 0.15)!
        self.view.backgroundColor = backgroundColor
        newAccountButton.setTitleColor(ContrastColorOf(backgroundColor, returnFlat: false), for: .normal)
        newAccountButton.backgroundColor = .clear
        continueButton.setTitleColor(ContrastColorOf(backgroundColor, returnFlat: false), for: .normal)
        continueButton.backgroundColor = .clear
        continueButton.isHidden = true
        backButton.setTitleColor(ContrastColorOf(backgroundColor, returnFlat: false), for: .normal)
        backButton.backgroundColor = .clear
        backButton.isHidden = true
        alertImage.isHidden = true

        promptView = QSPromptView(frame: CGRect(x: 80, y: 260, width: 225, height: 50))
        promptView.promptLabel.text = "Tap 'Create New Account'"

        let guideView = QSGuideLarge(frame: CGRect(x: 0, y: 0, width: 275, height: 220))
        guideView.guideLabel.text =
            "Pippip is a secure message service." +
            "\n\nWhat makes Pippip different is its unique contact system, airtight privacy, " +
            "and strong authentication."
        guideView.center = self.view.center
        self.view.addSubview(guideView)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(guideDismissed(_:)),
                                               name: Notifications.GuideDismissed, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notifications.GuideDismissed, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func newAccountSelected(_ sender: Any) {

        promptView.removeFromSuperview()
        alertImage.isHidden = false
        let guideView = QSGuideLarge(frame: CGRect(x: 0, y: 0, width: 275, height: 220))
        guideView.guideLabel.text =
            "The account name and passphrase you choose are only used on your device. " +
            "They are never sent to the server. Choose a passphrase you can easily remember. " +
            "It cannot be recovered."
        let center = self.view.center
        guideView.center = CGPoint(x: center.x, y: center.y + 200)
        self.view.addSubview(guideView)
        guide = "second"

    }

    @IBAction func backSelected(_ sender: Any) {

        self.dismiss(animated: true, completion: nil)

    }

    @objc func guideDismissed(_ notification: Notification) {

        DispatchQueue.main.async {
            self.backButton.isHidden = false
            if self.guide == "first" {
                self.view.addSubview(self.promptView)
            }
            else if self.guide == "second" {
                self.alertImage.isHidden = true
                self.newAccountButton.isEnabled = false
                self.continueButton.isHidden = false
            }
        }

    }

    // MARK: - Navigation

    @IBAction func unwindToAuthView(sender: UIStoryboardSegue) {
        
    }
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
