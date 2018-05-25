//
//  DeleteContactData.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/31/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import PMAlertController
import RKDropdownAlert
import ChameleonFramework

class DeleteContactSelector: ExpandingTableCellSelectorProtocol {
    
    var viewController: UIViewController?
    var tableView: ExpandingTableView?
    var selectedPath: IndexPath?
    var contactManager = ContactManager()
    var publicId: String
    var status: String
    var alertPresenter = AlertPresenter()

    init(publicId: String, status: String) {

        self.publicId = publicId
        self.status = status

    }
    
    func didSelect(indexPath: IndexPath, cell: UITableViewCell) {

        NotificationCenter.default.addObserver(self, selector: #selector(contactDeleted(_:)),
                                               name: Notifications.ContactDeleted, object: nil)


        var offset = 3
        if status == "pending" {
            offset = 4
        }
        selectedPath = IndexPath(row: indexPath.item-offset, section: indexPath.section)
        let message = "This contact and associated messages will be deleted\n"
                        + "This cannot be undone\n"
                        + "Proceed?"
        let alert = PMAlertController(title: "Caution!",
                                      description: message,
                                      image: nil,
                                      style: PMAlertControllerStyle.alert)
        alert.addAction(PMAlertAction(title: "Yes",
                                      style: .cancel, action: { () in
                                        self.contactManager.deleteContact(self.publicId)
        }))
        alert.addAction(PMAlertAction(title: "No", style: .default))
        viewController?.present(alert, animated: true, completion: nil)

    }
    
    @objc func contactDeleted(_ notification: Notification) {
        
        NotificationCenter.default.removeObserver(self, name: Notifications.ContactDeleted, object: nil)

        self.alertPresenter.successAlert(title: "Contact Deleted",
                                         message: "This contact has been removed from your contacts list")
        DispatchQueue.main.async {
            self.tableView?.expandingModel?.removeExpandingCell(section: self.selectedPath!.section,
                                                                row: self.selectedPath!.row, animation: .left)
        }
        
    }
    
}
