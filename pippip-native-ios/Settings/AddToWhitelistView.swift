//
//  AddToWhitelistView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 8/10/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class AddToWhitelistView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var directoryIdTextField: UITextField!
    @IBOutlet weak var publicIdTextField: UITextField!
    @IBOutlet weak var addIdButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    var whitelistViewController: WhitelistViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("AddToWhitelistView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        titleLabel.textColor = PippipTheme.titleColor
        titleLabel.backgroundColor = PippipTheme.lightBarColor
        addIdButton.backgroundColor = PippipTheme.buttonColor
        addIdButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        cancelButton.backgroundColor = PippipTheme.cancelButtonColor
        cancelButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)
        
    }
    
    @IBAction func addIdTapped(_ sender: Any) {
    }
    
    @IBAction func cancelTapped(_ sender: Any) {

        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
        }, completion: { completed in
            self.removeFromSuperview()
        })
        
    }

}
