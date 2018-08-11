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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
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
        addContactButton.backgroundColor = PippipTheme.buttonColor
        addContactButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        cancelButton.backgroundColor = PippipTheme.cancelButtonColor
        cancelButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)

    }

    func dismiss(completion: @escaping (Bool)->()) {
        

        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.contactsViewController?.blurView.alpha = 0.0
        }, completion: { completed in
            completion(completed)
        })
        
    }

    @IBAction func addContactTapped(_ sender: Any) {
    
        let directoryId = directoryIdTextField.text ?? ""
        let publicId = publicIdTextField.text ?? ""
        contactsViewController?.validateAndRequest(publicId: publicId, directoryId: directoryId)

    }

    @IBAction func cancelTapped(_ sender: Any) {

        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.contactsViewController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.removeFromSuperview()
        })
        
    }

}
