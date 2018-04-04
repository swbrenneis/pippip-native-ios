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

class DeleteContactData: CellDataProtocol {

    var cell: UITableViewCell
    var cellHeight: CGFloat
    var selector: ExpandingTableSelectorProtocol
    var userData: [String : Any]?
    
    init(publicId: String, viewController: ContactsViewController) {
        cell = viewController.tableView.dequeueReusableCell(withIdentifier: "DeleteContactCell")!
        cellHeight = 50.0
        selector = DeleteContactSelector(publicId, viewController: viewController)
    }
    
}

class DeleteContactSelector: ExpandingTableSelectorProtocol {
    
    var contactManager: ContactManager
    var publicId: String
    weak var viewController: ContactsViewController?
    var contactPath: IndexPath?
    
    init(_ publicId: String, viewController: ContactsViewController) {
        
        self.publicId = publicId
        contactManager = ContactManager()
        self.viewController = viewController
        
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
            self.viewController?.tableView.collapseRow(at: self.contactPath!, count: 3)
            if let model = self.viewController?.tableView.expandingModel {
                let _ = model.removeCell(section: self.contactPath!.section, row: self.contactPath!.row)
                self.viewController?.tableView.deleteRows(at: model.deletePaths, with: .right)
            }
        }
        
    }
    
}
