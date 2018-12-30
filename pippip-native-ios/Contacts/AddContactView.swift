//
//  AddContactView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 8/10/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import DLRadioButton

enum IdType { case publicId, directoryId }

class AddContactView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addContactButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var publicIdButton: DLRadioButton!
    @IBOutlet weak var directoryIdButton: DLRadioButton!
    @IBOutlet weak var contactIdText: UITextField!
    
    var contactsViewController: ContactsViewController?
    var idType: IdType
    var publicIdValid = false
    var publicIdRegex: NSRegularExpression

    override init(frame: CGRect) {
        
        publicIdRegex = try! NSRegularExpression(pattern: "[a-fA-F0-9]{40}", options: .caseInsensitive)
        idType = .directoryId
        
        super.init(frame: frame)
        commonInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        publicIdRegex = try! NSRegularExpression(pattern: "[a-fA-F0-9]{40}", options: .caseInsensitive)
        idType = .directoryId

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
        directoryIdButton.iconColor = PippipTheme.buttonColor
        directoryIdButton.indicatorColor = PippipTheme.buttonColor
        directoryIdButton.titleLabel?.textColor = PippipTheme.buttonColor
        publicIdButton.iconColor = PippipTheme.buttonColor
        publicIdButton.indicatorColor = PippipTheme.buttonColor
        publicIdButton.titleLabel?.textColor = PippipTheme.buttonColor
        addContactButton.backgroundColor = PippipTheme.buttonColor.withAlphaComponent(0.5)
        addContactButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        addContactButton.isEnabled = false
        cancelButton.backgroundColor = PippipTheme.cancelButtonColor
        cancelButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)

    }

    func checkIdValid() {
        
        let contactId = contactIdText.text ?? ""
        var idValid = false
        switch idType {
        case .directoryId:
            idValid = contactId.count > 0
            break
        case .publicId:
            let matches = publicIdRegex.matches(in: contactId, options: [], range: NSRange(location: 0, length: contactId.utf8.count))
            idValid = matches.count == 1
            break
        }
        if idValid {
            addContactButton.isEnabled = true
            addContactButton.backgroundColor = PippipTheme.buttonColor
        }
        else {
            addContactButton.isEnabled = false
            addContactButton.backgroundColor = PippipTheme.buttonColor.withAlphaComponent(0.5)
        }

    }
    
    func dismiss() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.contactsViewController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.contactIdText.resignFirstResponder()
            self.removeFromSuperview()
            self.contactsViewController?.addContactView = nil
        })
        
    }

    @IBAction func directoryIdSelected(_ sender: Any) {
        idType = .directoryId
        checkIdValid()
    }
    
    @IBAction func publicIdSelected(_ sender: Any) {
        idType = .publicId
        checkIdValid()
    }
    
    @IBAction func addContactTapped(_ sender: Any) {

        let contactId = contactIdText.text ?? ""
        var publicId: String?
        var directoryId: String?
        switch idType {
        case .directoryId:
            directoryId = contactId
            break
        case .publicId:
            publicId = contactId
            break
        }
        self.contactIdText.resignFirstResponder()
        contactsViewController?.showInitialMessageView(publicId: publicId, directoryId: directoryId)

    }

    @IBAction func cancelTapped(_ sender: Any) {

        dismiss()
        
    }
    
    @IBAction func contactIdChanged(_ sender: Any) {
        checkIdValid()
    }
    
}
