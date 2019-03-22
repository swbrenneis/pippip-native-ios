//
//  InitialMessageView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/18/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import UIKit

class InitialMessageView: UIView, Dismissable {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var laterButton: UIButton!
    
    var blurView: GestureBlurView?
    var contactRequest: ContactRequest?
    var contactManager = ContactManager()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()

    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("InitialMessageView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1.5
        contentView.layer.borderColor = PippipTheme.viewBorderColor.cgColor
        contentView.layer.masksToBounds = true

        contentView.backgroundColor = PippipTheme.viewColor
        viewButton.backgroundColor = PippipTheme.navBarColor
        viewButton.setTitleColor(PippipTheme.navBarTint, for: .normal)
        acceptButton.backgroundColor = PippipTheme.buttonColor
        acceptButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        hideButton.backgroundColor = PippipTheme.cancelButtonColor
        hideButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)
        rejectButton.backgroundColor = PippipTheme.rejectButtonColor
        rejectButton.setTitleColor(PippipTheme.rejectButtonTextColor, for: .normal)
        laterButton.backgroundColor = PippipTheme.cancelButtonColor
        laterButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)

    }
    
    func setRequest(_ contactRequest: ContactRequest) {
        
        self.contactRequest = contactRequest
        titleLabel.text = "You have a new message from \(contactRequest.displayId)"
        
    }

    func dismiss() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.blurView?.alpha = 0.0
        }, completion: { completed in
        })
        
    }
    
    @IBAction func viewTapped(_ sender: Any) {

        // Acknowledge with a pending status to get the initial message from the requesting ID
        contactManager.acknowledgeRequest(contactRequest: contactRequest!, response: Contact.PENDING)
        
    }
    
    @IBAction func acceptTapped(_ sender: Any) {
    }

    @IBAction func hideTapped(_ sender: Any) {
    }
    
    @IBAction func rejectTapped(_ sender: Any) {
    }

    @IBAction func laterTapped(_ sender: Any) {

        dismiss()
        
    }
}
