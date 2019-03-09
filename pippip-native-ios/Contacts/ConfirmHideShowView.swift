//
//  ConfirmHideShowView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/26/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import UIKit

class ConfirmHideShowView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var confirmLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!

    var action: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
        Bundle.main.loadNibNamed("ConfirmHideShowView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        confirmLabel.textColor = PippipTheme.titleColor
        yesButton.backgroundColor = PippipTheme.buttonColor
        yesButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        noButton.backgroundColor = PippipTheme.cancelButtonColor
        noButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)
        
    }
    
    func dismiss() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
        }, completion: { completed in
        })
        
    }
    

    @IBAction func yesTapped(_ sender: Any) {
        
        action?()
        dismiss()
        
    }
    
    @IBAction func noTapped(_ sender: Any) {
    
        dismiss()
        
    }
    
}
