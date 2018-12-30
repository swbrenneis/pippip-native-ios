//
//  InitialMessageView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework
import CocoaLumberjack

class InitialMessageView: UIView, Dismissable {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    var contactsViewController: ContactsViewController?
    var publicId: String?
    var directoryId: String?
    var alertPresenter = AlertPresenter()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
        
    }
    
    func commonInit() {
        
        Bundle.main.loadNibNamed("InitialMessageView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        titleLabel.textColor = PippipTheme.titleColor
        titleLabel.backgroundColor = PippipTheme.lightBarColor
        sendButton.backgroundColor = PippipTheme.buttonColor
        sendButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        sendButton.isEnabled = false
        cancelButton.backgroundColor = PippipTheme.cancelButtonColor
        cancelButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)
        messageTextView.layer.borderColor = UIColor.flatTeal.withAlphaComponent(0.6).cgColor
        
    }

    func addContact(response: AddContactResponse) {
        
        guard let serverContact = response.contact else {
            DDLogError("Invalid server response, server contact missing")
            alertPresenter.errorAlert(title: "Add Contact Error", message: Strings.errorInvalidResponse)
            return
        }
        let contact = Contact(serverContact: serverContact)
        do {
            try ContactsModel.instance.addPendingContact(contact)
            AsyncNotifier.notify(name: Notifications.ContactRequested, object: contact)
        }
        catch ContactError.duplicateContact {
            DDLogError("Duplicate contact: \(contact.publicId!)")
            alertPresenter.errorAlert(title: "Add Contact Error", message: Strings.errorDuplicateContact)
        }
        catch {
            DDLogError("Contact request error: \(error.localizedDescription)")
            alertPresenter.errorAlert(title: "Add Contact Error", message: Strings.errorInternal)
        }

    }
    
    func dismiss() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
        }, completion: { completed in
            self.messageTextView.resignFirstResponder()
            self.removeFromSuperview()
            self.contactsViewController?.messageView = nil
            self.contactsViewController?.addContactView?.dismiss()
        })
        
    }
    
    func onError(error: String) {
        
    }
    
    func onResponse(response: AddContactResponse) {

        guard let result = response.result else {
            DDLogError("Invalid server response, missing missing")
            alertPresenter.errorAlert(title: "Add Contact Error", message: Strings.errorInvalidResponse)
            return
        }
        if result == AddContactResponse.ID_NOT_FOUND {
            DDLogError("Directory ID \(directoryId!) not found")
            alertPresenter.errorAlert(title: "Add Contact Error", message: Strings.errorIdNotFound)
        }
        else if result == AddContactResponse.DUPLICATE_CONTACT {
            DDLogError("Duplicate contact")
            alertPresenter.errorAlert(title: "Add Contact Error", message: Strings.errorDuplicateContact)
        }
        else if result == AddContactResponse.DUPLICATE_REQUEST {
            DDLogError("Duplicate request")
            alertPresenter.errorAlert(title: "Add Contact Error", message: Strings.errorDuplicateRequest)
        }
        else if result == AddContactResponse.PENDING {
            addContact(response: response)
        }
        else {
            DDLogError("Invalid result from server: \(result)")
            alertPresenter.errorAlert(title: "Add Contact Error", message: Strings.errorInvalidResponse)
        }

    }
    
    @IBAction func sendTapped(_ sender: Any) {

        dismiss()
        let config = Configurator()
        let alertPresenter = AlertPresenter()
        if directoryId == config.directoryId || publicId == SessionState.instance.publicId {
            alertPresenter.errorAlert(title: "Add Contact Error", message: "Adding yourself is not allowed")
        }
        else if ContactsModel.instance.contactRequestExists(publicId: publicId, directoryId: directoryId) {
            alertPresenter.errorAlert(title: "Add Contact Error", message: "There is an existing request for that contact")
        }
        let contactManager = ContactManager()
        do {
            let contact = Contact()
            contact.publicId = publicId
            contact.directoryId = directoryId
            if let initialMessage = messageTextView.text,
                initialMessage.count > 0{
                contact.initialMessage = initialMessage
            }
            try contactManager.requestContact(contact: contact, retry: false,
                                              onResponse: { response in self.onResponse(response: response) },
                                              onError: { error in self.onError(error: error) })
        }
        catch {
            
        }

    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        
        dismiss()
        
    }
    
}
