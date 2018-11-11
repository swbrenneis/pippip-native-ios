//
//  DuplicateIdView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 11/9/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework

class DuplicateIdView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newIdTextField: UITextField!
    @IBOutlet weak var changeIdButton: UIButton!
    @IBOutlet weak var acceptIdButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var contactRequestsView: ContactRequestsView?
    var contactRequest: ContactRequest?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {

        Bundle.main.loadNibNamed("DuplicateIdView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        titleLabel.textColor = PippipTheme.titleColor
        titleLabel.backgroundColor = PippipTheme.lightBarColor
        changeIdButton.backgroundColor = PippipTheme.buttonColor.withAlphaComponent(0.5)
        changeIdButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        changeIdButton.isEnabled = false
        acceptIdButton.backgroundColor = UIColor.flatOrangeDark
        acceptIdButton.setTitleColor(ContrastColorOf(UIColor.flatOrangeDark, returnFlat: true), for: .normal)
        cancelButton.backgroundColor = PippipTheme.cancelButtonColor
        cancelButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)

        newIdTextField.becomeFirstResponder()

    }
    
    func dismiss() {

        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.contactRequestsView?.blurView.alpha = 0.0
        }, completion: { completed in
            self.newIdTextField.resignFirstResponder()
        })
        
    }
    
    @IBAction func changeIdTapped(_ sender: Any) {
        
        if var request = contactRequest {
            request.directoryId = newIdTextField.text
            ContactManager.instance.acknowledgeRequest(contactRequest: request, response: "accept")
            dismiss()
        }

    }
    
    @IBAction func acceptIdTapped(_ sender: Any) {
        
        if let request = contactRequest {
            ContactManager.instance.acknowledgeRequest(contactRequest: request, response: "accept")
            dismiss()
        }
        
    }
    
    @IBAction func cancelTapped(_ sender: Any) {

        dismiss()
        contactRequestsView?.ackCanceled()

    }
    
    @IBAction func newIdChanged(_ sender: Any) {
        
        changeIdButton.backgroundColor = PippipTheme.buttonColor
        changeIdButton.isEnabled = true
        
    }
}
