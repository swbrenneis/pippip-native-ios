//
//  AcknowledgeContactView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 8/20/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework

class AcknowledgeRequestView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    var contactManager = ContactManager()
    var contactsViewController: ContactsViewController?
    var contactRequest: ContactRequest? {
        didSet {
            promptLabel.text = "New contact request from \(contactRequest!.displayId)"
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
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("AcknowledgeRequestView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        titleLabel.textColor = PippipTheme.titleColor
        titleLabel.backgroundColor = PippipTheme.lightBarColor
        acceptButton.backgroundColor = PippipTheme.buttonColor
        acceptButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        deleteButton.backgroundColor = UIColor.flatGrayDark
        deleteButton.setTitleColor(ContrastColorOf(UIColor.flatGrayDark, returnFlat: true), for: .normal)
        rejectButton.backgroundColor = UIColor.flatOrange
        rejectButton.setTitleColor(ContrastColorOf(UIColor.flatOrange, returnFlat: true), for: .normal)
        cancelButton.backgroundColor = PippipTheme.cancelButtonColor
        cancelButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)
        
    }
    
    @IBAction func acceptTapped(_ sender: Any) {

        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.contactsViewController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.removeFromSuperview()
            self.contactManager.acknowledgeRequest(contactRequest: self.contactRequest!, response: "accept")
        })
        
    }
    
    @IBAction func deleteTapped(_ sender: Any) {

        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.contactsViewController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.removeFromSuperview()
            self.contactManager.acknowledgeRequest(contactRequest: self.contactRequest!, response: "ignore")
        })
        
    }
    
    @IBAction func rejectTapped(_ sender: Any) {

        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.contactsViewController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.removeFromSuperview()
            self.contactManager.acknowledgeRequest(contactRequest: self.contactRequest!, response: "reject")
        })
        
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
