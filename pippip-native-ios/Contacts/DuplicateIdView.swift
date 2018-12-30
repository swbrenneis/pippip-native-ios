//
//  DuplicateIdView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 11/9/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework
import CocoaLumberjack

class DuplicateIdView: UIView, ObserverProtocol {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newIdTextField: UITextField!
    @IBOutlet weak var changeIdButton: UIButton!
    @IBOutlet weak var acceptIdButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var contactRequestsView: ContactRequestsView?
    var contactRequest: ContactRequest?
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
    
    func acknowledgeRequest(publicId: String) {
        
        let contactManager = ContactManager()
        do {
            try contactManager.acknowledgeRequest(publicId: publicId, response: "accept",
                                                  onResponse: { response -> Void in self.onResponse(response: response) },
                                                  onError: { error in self.onError(error: error) })
        }
        catch {
            DDLogError("Acknowledge request error: \(error.localizedDescription)")
            alertPresenter.errorAlert(title: "Contact Request Error", message: Strings.errorServerResponse)
        }

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
    
    func onError(error: String) {
        DDLogError("Acknowledge request response error: \(error)")
        alertPresenter.errorAlert(title: "Contact Request Error", message: Strings.errorServerResponse)
    }
    
    func onResponse(response: AcknowledgeRequestResponse) {

        if let error = response.error {
            DDLogError("Acknowledge request response error: \(error)")
            alertPresenter.errorAlert(title: "Contact Request Error", message: Strings.errorServerResponse)
        }
        else {
            guard let acknowledged = response.acknowledged else {
                alertPresenter.errorAlert(title: "Contact Request Error", message: Strings.errorInvalidResponse)
                return
            }
            do {
                contact = Contact(serverContact: acknowledged)
                ContactsModel.instance.addObserver(action: .added, observer: self)
                try ContactsModel.instance.addContact(contact: contact!)
            }
            catch {
                DDLogError("Error adding acknowledged contact: \(error.localizedDescription)")
                alertPresenter.errorAlert(title: "Contact Request Error", message: Strings.errorInternal)
            }
        }
        
    }

    func update(observable: ObservableProtocol, object: Any?) {

        guard let contactsModel = object as? ContactsModel else { return }
        contactsModel.removeObserver(action: .added, observer: self)
        do {
            try contactsModel.contactAcknowledged(contact: contact!)
            contactsModel.deleteContactRequest(contactRequest!)
        }
        catch {
            DDLogError("Update error: \(error.localizedDescription)")
            alertPresenter.errorAlert(title: "Contact Request Error", message: Strings.errorInternal)
        }

    }
    
    @IBAction func changeIdTapped(_ sender: Any) {
        
        if var request = contactRequest {
            guard let publicId = request.publicId else { return }
            request.directoryId = newIdTextField.text
            acknowledgeRequest(publicId: publicId)
            dismiss()
        }

    }
    
    @IBAction func acceptIdTapped(_ sender: Any) {
        
        if let request = contactRequest {
            guard let publicId = request.publicId else { return }
            acknowledgeRequest(publicId: publicId)
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
