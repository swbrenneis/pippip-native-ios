//
//  AuthViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController {

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var logoTrailing: NSLayoutConstraint!
    @IBOutlet weak var logoTop: NSLayoutConstraint!
    @IBOutlet weak var logoLeading: NSLayoutConstraint!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var quickstartButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var secommLabel: UILabel!
    
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
        authButton.setTitleColor(PippipTheme.buttonMediumTextColor, for: .normal)
        authButton.backgroundColor = .clear
        quickstartButton.setTitleColor(PippipTheme.buttonMediumTextColor, for: .normal)
        quickstartButton.backgroundColor = .clear
        versionLabel.textColor = UIColor.flatWhite
        secommLabel.textColor = UIColor.flatWhite

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
