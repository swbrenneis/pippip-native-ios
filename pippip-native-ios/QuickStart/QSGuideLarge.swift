//
//  QSGuideLarge.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/18/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework

class QSGuideLarge: UIView {

    @IBOutlet var contentView: QSGuideLarge!
    @IBOutlet weak var guideLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        Bundle.main.loadNibNamed("QSGuideLarge", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = UIColor.flatSand
        guideLabel.textColor = UIColor.flatRedDark
        okButton.setTitleColor(UIColor.flatRedDark, for: .normal)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func okSelected(_ sender: Any) {
        self.removeFromSuperview()
        NotificationCenter.default.post(name: Notifications.GuideDismissed, object: nil)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
