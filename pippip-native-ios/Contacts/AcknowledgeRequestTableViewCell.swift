//
//  AcknowledgeRequestTableViewCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/28/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework
import CocoaLumberjack

enum CellType {
    case accept
    case ignore
    case reject
    // case cancel
}

class AcknowledgeRequestTableViewCell: UITableViewCell, ObserverProtocol {

    @IBOutlet weak var nibView: UIView!
    @IBOutlet weak var acknowledgeButton: UIButton!
    
    var cellType: CellType!
    var contactRequest: ContactRequest?
    var contact: Contact?
    var contactsViewController: ContactsViewController?
    var request: ContactRequest?
    var confirmationView: DuplicateIdView?
    var alertPresenter = AlertPresenter()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func acknowledgeRequest(publicId: String, action: String) {
        
        let contactManager = ContactManager()
        do {
            try contactManager.acknowledgeRequest(publicId: publicId, response: action,
                                                  onResponse: { response -> Void in self.onResponse(response: response) },
                                                  onError: { error in self.onError(error: error) })
        }
        catch {
            DDLogError("Acknowledge request error: \(error.localizedDescription)")
            alertPresenter.errorAlert(title: "Contact Request Error", message: Strings.errorServerResponse)
        }
        
    }
    
    func checkAndAccept(contactRequest: ContactRequest) -> Bool {
        
        guard let directoryId = contactRequest.directoryId else { return true }
        if let _ = ContactsModel.instance.getPublicId(directoryId: directoryId) {
            showConfirmationView(contactRequest: contactRequest)
            return false
        }
        else {
            return true
        }

    }

    func configure(cellType: CellType, selected: ContactRequest, viewController: ContactsViewController?) {

        self.contactRequest = selected
        self.cellType = cellType
        self.contactsViewController = viewController

        switch cellType {
        case .accept:
            acknowledgeButton.setTitle("Accept", for: .normal)
            acknowledgeButton.backgroundColor = PippipTheme.buttonColor
            acknowledgeButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
            break
        case .ignore:
            acknowledgeButton.setTitle("Hide", for: .normal)
            acknowledgeButton.backgroundColor = UIColor.flatGrayDark
            acknowledgeButton.setTitleColor(ContrastColorOf(UIColor.flatGrayDark, returnFlat: true), for: .normal)
            break
        case .reject:
            acknowledgeButton.setTitle("Reject", for: .normal)
            acknowledgeButton.backgroundColor = UIColor.flatOrange
            acknowledgeButton.setTitleColor(ContrastColorOf(UIColor.flatOrange, returnFlat: true), for: .normal)
            break
        }

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
    
    func setSelected(selected: ContactRequest) {
        contactRequest = selected
    }

    private func showConfirmationView(contactRequest: ContactRequest) {
        
        if let viewController = contactsViewController {
            let bounds = viewController.view.bounds
            let width = bounds.width * 0.7
            let height = bounds.height * 0.55
            let viewRect = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            //var viewCenter = viewController.view.center
            //viewCenter.y = viewCenter.y + height / 2
            confirmationView = DuplicateIdView(frame: viewRect)
            confirmationView?.center = viewController.view.center
            confirmationView?.contactRequest = contactRequest
//            confirmationView?.contactRequestsView = reqView
            confirmationView?.alpha = 0.0
            
            viewController.view.addSubview(confirmationView!)
            viewController.blurView.toDismiss = nil
            
            UIView.animate(withDuration: 0.3, animations: {
//                self.reqView?.blurView.alpha = 0.6
                self.confirmationView?.alpha = 1.0
            })
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
    
    @IBAction func acknowledgeTapped(_ sender: Any) {

        guard let request = contactRequest else { return }
        guard let puid = request.publicId else { return }
        
        let contactsModel = ContactsModel.instance
        if let _ = contactsModel.getContact(publicId: request.publicId!) {
            alertPresenter.errorAlert(title: "Acknowledge Contact Error", message: "This contact already exists in your contacts")
            contactsModel.deleteContactRequest(request)
        }
        else {
            switch cellType! {
            case .accept:
                if checkAndAccept(contactRequest: request) {
                    acknowledgeRequest(publicId: puid, action: AcknowledgeRequest.accept)
                }
                break
            case .ignore:
                acknowledgeRequest(publicId: puid, action: AcknowledgeRequest.ignore)
                break
            case .reject:
                acknowledgeRequest(publicId: puid, action: AcknowledgeRequest.reject)
                break
            }
        }
    }

}
