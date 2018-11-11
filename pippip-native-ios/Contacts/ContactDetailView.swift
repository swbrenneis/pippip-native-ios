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
    
    var contactsViewController: ContactsViewController?
    var tapGesture: UITapGestureRecognizer?
    var publicId = ""
    var newId: String?
    var alertPresenter = AlertPresenter()
    var contact: Contact?
    var confirmationView: DuplicateIdConfirmationView?
    
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
    
    func forceDismiss() {

        confirmationView?.dismiss()
        doDismiss()

    }
    
    func dismiss() {

        if let directoryId = newId, newId != contact?.directoryId {    // Directory ID has been changed
            let contactManager = ContactManager.instance
            if let _ = contactManager.getPublicId(directoryId: directoryId) {
                showConfirmationView()
            }
            else {
                contactManager.setDirectoryId(contactId: contact!.contactId, directoryId: directoryId)
                doDismiss()
            }
        }
        else {
            doDismiss()
        }
    
    }

    private func doDismiss() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.contactsViewController?.blurView.alpha = 0.0
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
            let height = bounds.height * 0.35
            let viewRect = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            //var viewCenter = viewController.view.center
            //viewCenter.y = viewCenter.y + height / 2
            confirmationView = DuplicateIdConfirmationView(frame: viewRect)
            confirmationView?.center = viewController.view.center
            confirmationView?.contactDetailView = self
            confirmationView?.contact = contact
            confirmationView?.newId = directoryIdTextField.text
            confirmationView?.alpha = 0.0
            
            viewController.view.addSubview(confirmationView!)
            viewController.blurView.toDismiss = nil
            
            UIView.animate(withDuration: 0.3, animations: {
                viewController.blurView.alpha = 0.6
                self.confirmationView?.alpha = 1.0
            })
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
        
        let newId = directoryIdTextField.text
        let contactManager = ContactManager.instance
        if let _ = contactManager.getPublicId(directoryId: newId!) {
            showConfirmationView()
        }
        else {
            contactManager.setDirectoryId(contactId: contact!.contactId, directoryId: newId)
        }
        directoryIdSetButton.isHidden = true
    
    }

    @IBAction func directoryIdChanged(_ sender: Any) {
        
        newId = directoryIdTextField.text!
//        directoryIdSetButton.isHidden = directoryId == contact!.directoryId
        
    }

}
