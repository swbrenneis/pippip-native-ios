//
//  ContactDetailView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/14/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import CocoaLumberjack
import ChameleonFramework

class ContactDetailView: UIView, Dismissable {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var directoryIdTextField: UITextField!
    @IBOutlet weak var publicIdLabel: UILabel!
    @IBOutlet weak var lastSeenTitle: UILabel!
    @IBOutlet weak var lastSeenLabel: UILabel!
    @IBOutlet weak var resendRequestButton: UIButton!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var directoryIdSetButton: UIButton!
    @IBOutlet weak var ignoreContactButton: UIButton!
    @IBOutlet weak var showContactButton: UIButton!
    
    var contactsViewController: ContactsViewController?
    var tapGesture: UITapGestureRecognizer?
    var publicId = ""
    var newId: String?
    var alertPresenter = AlertPresenter()
    var contact: Contact! {
        didSet {
            if contact.status == "pending" {
                resendRequestButton.isHidden = false
                ignoreContactButton.isHidden = true
                showContactButton.isHidden = true
            } else if contact.status == "ignored" {
                resendRequestButton.isHidden = true
                ignoreContactButton.isHidden = true
                showContactButton.isHidden = false
            } else {
                resendRequestButton.isHidden = true
                ignoreContactButton.isHidden = false
                showContactButton.isHidden = true
            }
        }
    }
    var confirmationView: DuplicateIdConfirmationView?
    var confirmHideShowView: ConfirmHideShowView?
    
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
        
        ignoreContactButton.backgroundColor = UIColor.flatGrayDark
        ignoreContactButton.setTitleColor(ContrastColorOf(UIColor.flatGrayDark, returnFlat: true), for: .normal)

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        tapGesture!.numberOfTapsRequired = 1
        tapGesture!.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tapGesture!)

    }
    
    func dismiss() {

        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.contactsViewController?.blurView.alpha = 0.0
            self.confirmationView?.dismiss()
            self.confirmHideShowView?.dismiss()
        }, completion: { completed in
            self.contactsViewController?.blurView.toDismiss = nil
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
    
    func showConfirmationView() {
        
        if let viewController = contactsViewController {
            let bounds = viewController.view.bounds
            let width = bounds.width * 0.7
            let viewRect = CGRect(x: 0.0, y: 0.0, width: width, height: 240.0)
            confirmationView = DuplicateIdConfirmationView(frame: viewRect)
            confirmationView?.center = viewController.view.center
            confirmationView?.contactDetailView = self
            confirmationView?.contact = contact
            confirmationView?.newId = directoryIdTextField.text
            confirmationView?.layer.borderWidth = 2.0
            confirmationView?.layer.borderColor = UIColor.flatGray.cgColor
            confirmationView?.layer.cornerRadius = 7.0
            confirmationView?.alpha = 0.0
            
            viewController.view.addSubview(confirmationView!)
            viewController.blurView.toDismiss = nil
            
            UIView.animate(withDuration: 0.3, animations: {
                viewController.blurView.alpha = 0.6
                self.confirmationView?.alpha = 1.0
            })
        }
        
    }
    
    func showHideShowView(verb: String, action: @escaping () -> Void) {
        
        if let viewController = contactsViewController {
            let bounds = viewController.view.bounds
            let width = bounds.width * 0.7
            let viewRect = CGRect(x: 0.0, y: 0.0, width: width, height: 120.0)
            confirmHideShowView = ConfirmHideShowView(frame: viewRect)
            confirmHideShowView?.center = viewController.view.center
            if let directoryId = contact?.directoryId {
                confirmHideShowView?.confirmLabel.text = verb + " " + directoryId + "?"
            } else {
                confirmHideShowView?.confirmLabel.text = verb + " this contact?"
            }
            confirmHideShowView?.action = action
            confirmHideShowView?.layer.borderWidth = 2.0
            confirmHideShowView?.layer.borderColor = UIColor.flatGray.cgColor
            confirmHideShowView?.layer.cornerRadius = 7.0
            confirmHideShowView?.alpha = 0.0
            
            viewController.view.addSubview(confirmHideShowView!)
            viewController.blurView.toDismiss = nil
            
            UIView.animate(withDuration: 0.3, animations: {
                viewController.blurView.alpha = 0.6
                self.confirmHideShowView?.alpha = 1.0
            })
        }
        
    }
    
    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        
            dismiss()
    
    }
    
    @IBAction func resendRequestTapped(_ sender: Any) {

        do {
            try ContactManager().addContactRequest(publicId: contact.publicId, directoryId: nil, pendingMessage: nil)
            alertPresenter.successAlert(message: "The request was resent to this contact")
        }
        catch {
            DDLogError("Error resending request: \(error.localizedDescription)")
            alertPresenter.errorAlert(title: "Send Request Error", message: "The request could not be sent")
        }
        
    }

    @IBAction func directoryIdSet(_ sender: Any) {
        
        let newId = directoryIdTextField.text
        if let _ = ContactsModel.instance.getPublicId(directoryId: newId!) {
            showConfirmationView()
        }
        else {
            ContactsModel.instance.setDirectoryId(contactId: contact!.contactId, directoryId: newId)
        }
        directoryIdSetButton.isHidden = true
    
    }

    @IBAction func directoryIdChanged(_ sender: Any) {
        
        if let directoryId = contact.directoryId {
            if directoryIdTextField.text == directoryId {
                directoryIdSetButton.isHidden = true
            } else {
                directoryIdSetButton.isHidden = false
            }
        } else {
            directoryIdSetButton.isHidden = false
        }
        newId = directoryIdTextField.text!
        
    }

    @IBAction func ignoreContactTapped(_ sender: Any) {
        
        showHideShowView(verb: "Block", action: ({() in
            ContactManager().hideContact(self.contact!)
        }))
        
    }

    @IBAction func showContactTapped(_ sender: Any) {
        
        showHideShowView(verb: "Allow", action: ({() in
            ContactManager().showContact(self.contact!)
        }))
        
    }

}
