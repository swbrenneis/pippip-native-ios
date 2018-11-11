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
    var publicId = ""
    var publicIdValid = false
    var directoryId = ""
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
        addIdButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        addIdButton.isEnabled = false
        addIdButton.backgroundColor = PippipTheme.buttonColor.withAlphaComponent(0.5)
        cancelButton.backgroundColor = PippipTheme.cancelButtonColor
        cancelButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)
        
    }
    
    func dismiss() {

        assert(Thread.isMainThread)
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

        var dirId: String? = directoryId
        if let did = dirId {
            if did.count == 0 {
                dirId = nil
            }
        }
        var pId: String? = publicId
        if let pid = pId {
            if pid.count == 0 {
                pId = nil
            }
        }
        whitelistViewController?.verifyAndAdd(directoryId: dirId, publicId: pId)

    }
    
    @IBAction func cancelTapped(_ sender: Any) {

        dismiss()

    }

    @IBAction func directoryIdChanged(_ sender: Any) {

        directoryId = directoryIdTextField.text ?? ""
        if (directoryId.count > 0 && publicId.count == 0) || (directoryId.count == 0 && publicIdValid)  {
            addIdButton.isEnabled = true
            addIdButton.backgroundColor = PippipTheme.buttonColor
        }
        else {
            addIdButton.isEnabled = false
            addIdButton.backgroundColor = PippipTheme.buttonColor.withAlphaComponent(0.5)
        }
        
    }

    @IBAction func publicIdChanged(_ sender: Any) {
        
        publicId = publicIdTextField.text ?? ""
        let matches = publicIdRegex.matches(in: publicId, options: [], range: NSRange(location: 0, length: publicId.utf8.count))
        publicIdValid = matches.count == 1
        if (directoryId.count > 0 && publicId.count == 0) || (directoryId.count == 0 && publicIdValid)  {
            addIdButton.isEnabled = true
            addIdButton.backgroundColor = PippipTheme.buttonColor
        }
        else {
            addIdButton.isEnabled = false
            addIdButton.backgroundColor = PippipTheme.buttonColor.withAlphaComponent(0.5)
        }

    }
    
}
