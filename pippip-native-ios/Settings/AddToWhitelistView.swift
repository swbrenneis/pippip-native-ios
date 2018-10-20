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
    var publicIdBlank = true
    var publicIdValid = false
    var directoryIdBlank = true
    var publicIdRegex: NSRegularExpression
    
    override init(frame: CGRect) {
        
        publicIdRegex = try! NSRegularExpression(pattern: "[a-fA-F0-9]{40}", options: .caseInsensitive)

        super.init(frame: frame)
        commonInit()

    }
    
    required init?(coder aDecoder: NSCoder) {

        publicIdRegex = try! NSRegularExpression(pattern: "[a-fA-F0-9]{40}", options: .caseInsensitive)

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
        addIdButton.isEnabled = false
        cancelButton.backgroundColor = PippipTheme.cancelButtonColor
        cancelButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)
        
    }
    
    func dismiss() {

        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.whitelistViewController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.directoryIdTextField.resignFirstResponder()
            self.publicIdTextField.resignFirstResponder()
            self.removeFromSuperview()
        })
        
    }

    @IBAction func addIdTapped(_ sender: Any) {

        let directoryId = directoryIdTextField.text ?? ""
        let publicId = publicIdTextField.text ?? ""
        whitelistViewController?.verifyAndAdd(directoryId: directoryId, publicId: publicId)

    }
    
    @IBAction func cancelTapped(_ sender: Any) {

        dismiss()

    }

    @IBAction func directoryIdChanged(_ sender: Any) {

        if let directoryId = directoryIdTextField.text {
            directoryIdBlank = directoryId.count == 0
        }
        addIdButton.isEnabled = (!directoryIdBlank && publicIdBlank) || (directoryIdBlank && publicIdValid)
        
    }

    @IBAction func publicIdChanged(_ sender: Any) {
        
        if let publicId = publicIdTextField.text {
            publicIdBlank = publicId.count == 0
            let matches = publicIdRegex.matches(in: publicId, options: [], range: NSRange(location: 0, length: publicId.utf8.count))
            publicIdValid = matches.count == 1
        }
        addIdButton.isEnabled = (!directoryIdBlank && publicIdBlank) || (directoryIdBlank && publicIdValid)

    }
    
}
