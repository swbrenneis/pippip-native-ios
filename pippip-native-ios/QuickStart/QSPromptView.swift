//
//  QSGuideSmall.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/18/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class QSPromptView: UIView {

    @IBOutlet var contentView: QSPromptView!
    @IBOutlet weak var promptLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed("QSPromptView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = UIColor.flatSand
        promptLabel.textColor = UIColor.flatRedDark
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
