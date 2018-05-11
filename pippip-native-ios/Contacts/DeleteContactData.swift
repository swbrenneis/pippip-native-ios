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

class DeleteContactData: NSObject, CellDataProtocol {

    var cellHeight: CGFloat = 50.0
    var cellId: String = "DeleteContactCell"
    var selector: ExpandingTableSelectorProtocol?
    var userData: [String : Any]?
    
    func configureCell(_ cell: UITableViewCell) {
        // noop
    }

}

class DeleteContactSelector: ExpandingTableSelectorProtocol {
    
    var viewController: UIViewController?
    var tableView: ExpandingTableView?
    var contactPath: IndexPath?
    var contactManager = ContactManager()
    var publicId: String

    init(_ publicId: String) {
        
        self.publicId = publicId
        
    }
    
    func didSelect(_ indexPath: IndexPath) {

        NotificationCenter.default.addObserver(self, selector: #selector(contactDeleted(_:)),
                                               name: Notifications.ContactDeleted, object: nil)
        
        contactPath = IndexPath(row: indexPath.item-3, section: indexPath.section)
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
    
    @objc func contactDeleted(_ : Notification) {
        
        NotificationCenter.default.removeObserver(self, name: Notifications.ContactDeleted, object: nil)

        DispatchQueue.main.async {
            let alertColor = UIColor.flatLime
            RKDropdownAlert.title("Contact Deleted", message: "This contact has been removed from your contacts list",
                                  backgroundColor: alertColor,
                                  textColor: ContrastColorOf(alertColor, returnFlat: true),
                                  time: 2, delegate: nil)
            self.tableView?.collapseRow(at: self.contactPath!)
            self.tableView?.expandingModel?.removeCell(section: self.contactPath!.section, row: self.contactPath!.row,
                                       with: .left)
        }
        
    }
    
}
