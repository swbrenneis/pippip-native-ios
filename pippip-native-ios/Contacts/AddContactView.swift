//
//  AddContactView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 8/10/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class AddContactView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var directoryIdTextField: UITextField!
    @IBOutlet weak var publicIdTextField: UITextField!
    @IBOutlet weak var addContactButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var contactsViewController: ContactsViewController?
    var directoryId = ""
    var publicId = ""
    var publicIdValid = false
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
        
        Bundle.main.loadNibNamed("AddContactView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        titleLabel.textColor = PippipTheme.titleColor
        titleLabel.backgroundColor = PippipTheme.lightBarColor
        addContactButton.backgroundColor = PippipTheme.buttonColor.withAlphaComponent(0.5)
        addContactButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        addContactButton.isEnabled = false
        cancelButton.backgroundColor = PippipTheme.cancelButtonColor
        cancelButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)

    }

    func dismiss() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.contactsViewController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.directoryIdTextField.resignFirstResponder()
            self.publicIdTextField.resignFirstResponder()
            self.removeFromSuperview()
            self.contactsViewController?.addContactView = nil
        })
        
    }

    @IBAction func addContactTapped(_ sender: Any) {
    
        let directoryId = directoryIdTextField.text ?? ""
        let publicId = publicIdTextField.text ?? ""
        directoryIdTextField.resignFirstResponder()
        publicIdTextField.resignFirstResponder()
        contactsViewController?.validateAndRequest(publicId: publicId, directoryId: directoryId)

    }

    @IBAction func cancelTapped(_ sender: Any) {

        dismiss()
        
    }
    
    @IBAction func directoryIdChanged(_ sender: Any) {

        directoryId = directoryIdTextField.text ?? ""
        if (directoryId.count > 0 && publicId.count == 0) || (directoryId.count == 0 && publicIdValid)  {
            addContactButton.isEnabled = true
            addContactButton.backgroundColor = PippipTheme.buttonColor
        }
        else {
            addContactButton.isEnabled = false
            addContactButton.backgroundColor = PippipTheme.buttonColor.withAlphaComponent(0.5)
        }
        
    }
    
    @IBAction func publicIdChanged(_ sender: Any) {
        
        publicId = publicIdTextField.text ?? ""
        let matches = publicIdRegex.matches(in: publicId, options: [], range: NSRange(location: 0, length: publicId.utf8.count))
        publicIdValid = matches.count == 1
        if (directoryId.count > 0 && publicId.count == 0) || (directoryId.count == 0 && publicIdValid)  {
            addContactButton.isEnabled = true
            addContactButton.backgroundColor = PippipTheme.buttonColor
        }
        else {
            addContactButton.isEnabled = false
            addContactButton.backgroundColor = PippipTheme.buttonColor.withAlphaComponent(0.5)
        }
        
    }

}
