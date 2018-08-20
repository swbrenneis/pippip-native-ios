//
//  Alert2ButtonView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 8/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class Alert2ButtonView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var oneButton: UIButton!
    @IBOutlet weak var twoButton: UIButton!

    var blurredController: ControllerBlurProtocol?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("Alert2ButtonView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        oneButton.backgroundColor = PippipTheme.buttonColor
        oneButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        twoButton.backgroundColor = PippipTheme.cancelButtonColor
        twoButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)

    }
    
    func buttonOneAction() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.blurredController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.removeFromSuperview()
        })
        
    }
    
    func buttonTwoAction() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.blurredController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.removeFromSuperview()
        })
        
    }
    
    @IBAction func buttonOneTapped(_ sender: Any) {

        buttonOneAction()
    
    }

    @IBAction func buttonTwoTapped(_ sender: Any) {
    
        buttonTwoAction()

    }

}
