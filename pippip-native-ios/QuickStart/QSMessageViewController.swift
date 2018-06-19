//
//  QSMessageViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/18/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework

class QSMessageViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backButton.setTitleColor(ContrastColorOf(PippipTheme.viewColor, returnFlat: false), for: .normal)
        backButton.backgroundColor = .clear

        let guideView = QSGuideLarge(frame: CGRect(x: 0, y: 0, width: 275, height: 220))
        guideView.guideLabel.text =
            "The message preview screen will be the first one you will see after creating a new account. " +
            "Follow the prompts to find out what each part of this screen does."
        guideView.center = self.view.center
        self.view.addSubview(guideView)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isStatusBarHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.isStatusBarHidden = false
        
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
