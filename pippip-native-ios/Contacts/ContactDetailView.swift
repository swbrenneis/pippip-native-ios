//
//  ContactDetailView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/14/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ContactDetailView: UIView, Dismissable {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var directoryIdTextField: UITextField!
    @IBOutlet weak var publicIdLabel: UILabel!
    @IBOutlet weak var lastSeenTitle: UILabel!
    @IBOutlet weak var lastSeenLabel: UILabel!
    @IBOutlet weak var resendRequestButton: UIButton!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var directoryIdSetButton: UIButton!
    
    var blurController: ControllerBlurProtocol?
    var tapGesture: UITapGestureRecognizer?
    var publicId = ""
    var alertPresenter = AlertPresenter()
    var contact: Contact?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("ContactDetailView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        resendRequestButton.backgroundColor = PippipTheme.buttonColor
        resendRequestButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        
        directoryIdSetButton.backgroundColor = PippipTheme.buttonColor
        directoryIdSetButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        directoryIdSetButton.isHidden = true

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        tapGesture!.numberOfTapsRequired = 1
        tapGesture!.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tapGesture!)

    }
    
    func dismiss() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.blurController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.blurController?.blurView.toDismiss = nil
            self.directoryIdTextField.resignFirstResponder()
        })
        
    }

    func setDetail(contact: Contact) {
        
        assert(Thread.isMainThread)
        self.contact = contact
        publicId = contact.publicId
        publicIdLabel.text = contact.publicId
        directoryIdTextField.text = contact.directoryId
        statusImageView.image = UIImage(named: contact.status)
        resendRequestButton.isHidden = contact.status != "pending"
        if (contact.timestamp == 0) {
            lastSeenLabel.text = "Never"
        }
        else {
            let lastSeenFormatter = DateFormatter()
            lastSeenFormatter.dateFormat = "MMM dd YYYY hh:mm a"
            lastSeenFormatter.locale = Locale(identifier: "en_US")
            let tsDate = Date.init(timeIntervalSince1970: TimeInterval(contact.timestamp))
            lastSeenLabel.text = lastSeenFormatter.string(from: tsDate)
        }

    }
    
    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        dismiss()
    }
    
    @IBAction func resendRequestTapped(_ sender: Any) {

        ContactManager.instance.requestContact(publicId: publicId, directoryId: nil, retry: true)
        alertPresenter.successAlert(message: "The request was resent to this contact")
        
    }

    @IBAction func directoryIdSet(_ sender: Any) {
        
        ContactManager.instance.setDirectoryId(contactId: contact!.contactId, directoryId: directoryIdTextField.text)
        directoryIdSetButton.isHidden = true
    
    }

    @IBAction func directoryIdChanged(_ sender: Any) {
        
        let directoryId = directoryIdTextField.text!
        directoryIdSetButton.isHidden = directoryId == contact!.directoryId
        
    }

}
