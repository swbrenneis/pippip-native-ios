//
//  DuplicateIdConfirmationView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 11/10/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class DuplicateIdConfirmationView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var keepButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var contact: Contact?
    var contactDetailView: ContactDetailView?
    var newId: String! {
        didSet {
            let labelText: String? = idLabel.text?.replacingOccurrences(of: "id", with: newId)
            idLabel.text = labelText
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {

        Bundle.main.loadNibNamed("DuplicateIdConfirmationView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        titleLabel.textColor = PippipTheme.titleColor
        titleLabel.backgroundColor = PippipTheme.lightBarColor
        keepButton.backgroundColor = PippipTheme.buttonColor
        keepButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        cancelButton.backgroundColor = PippipTheme.cancelButtonColor
        cancelButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)
        
    }
    
    func dismiss() {

        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
        }, completion: { completed in
            self.contactDetailView?.contactsViewController?.blurView.toDismiss = self.contactDetailView
        })
        
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        
        contactDetailView?.directoryIdTextField.text = contact?.directoryId
        contactDetailView?.newId = nil
        dismiss()
        
    }
    
    @IBAction func keepTapped(_ sender: Any) {

        ContactsModel.instance.setDirectoryId(contactId: contact!.contactId, directoryId: newId)
        contactDetailView?.forceDismiss()
        
    }

}
