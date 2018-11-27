//
//  AcknowledgeRequestTableViewCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/28/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework

enum CellType {
    case accept
    case ignore
    case reject
    // case cancel
}

class AcknowledgeRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var nibView: UIView!
    @IBOutlet weak var acknowledgeButton: UIButton!
    
    var cellType: CellType!
    var reqView: ContactRequestsView!
    var contactsViewController: ContactsViewController?
    var request: ContactRequest?
    var confirmationView: DuplicateIdView?
    var alertPresent = AlertPresenter()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func checkAndAccept(contactRequest: ContactRequest) -> Bool {
        
        guard let directoryId = contactRequest.directoryId else { return true }
        if let _ = ContactManager.instance.getPublicId(directoryId: directoryId) {
            showConfirmationView(contactRequest: contactRequest)
            return false
        }
        else {
            return true
        }

    }

    func configure(cellType: CellType, reqView: ContactRequestsView, viewController: ContactsViewController?) {
        
        self.reqView = reqView
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
            confirmationView?.contactRequestsView = reqView
            confirmationView?.alpha = 0.0
            
            viewController.view.addSubview(confirmationView!)
            viewController.blurView.toDismiss = nil
            
            UIView.animate(withDuration: 0.3, animations: {
                self.reqView?.blurView.alpha = 0.6
                self.confirmationView?.alpha = 1.0
            })
        }
        
    }
    
    @IBAction func acknowledgeTapped(_ sender: Any) {

        guard let request = reqView.selected else { return }
        reqView.selected = nil
        reqView.tableView.separatorStyle = .singleLine
        
        if let _ = ContactManager.instance.getContact(publicId: request.publicId) {
            alertPresent.errorAlert(title: "Acknowledge Contact Error", message: "This contact already exists in your contacts")
            ContactManager.instance.deleteContactRequest(request)
        }
        else {
            switch cellType! {
            case .accept:
                if checkAndAccept(contactRequest: request) {
                    ContactManager.instance.acknowledgeRequest(contactRequest: request, response: "accept")
                }
                break
            case .ignore:
                ContactManager.instance.acknowledgeRequest(contactRequest: request, response: "ignore")
                break
            case .reject:
                ContactManager.instance.acknowledgeRequest(contactRequest: request, response: "reject")
                break
            }
        }
    }

}
