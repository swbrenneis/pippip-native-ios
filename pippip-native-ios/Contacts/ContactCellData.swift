//
//  ContactCellData.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/31/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ContactCellData: CellDataProtocol {

    var cellId: String = "ContactCell"
    var cellHeight: CGFloat = ContactCell.cellHeight
    var selector: ExpandingTableSelectorProtocol?
    var userData: [String : Any]?
    var contact: Contact
    var contactCell: ContactCell?

    init(contact: Contact) {

        self.contact = contact

        NotificationCenter.default.addObserver(self, selector: #selector(pendingContactsUpdated(_:)),
                                               name: Notifications.PendingContactsUpdated, object: nil)

    }

    func configureCell(_ cell: UITableViewCell) {

        contactCell = cell as? ContactCell
        contactCell?.identLabel.text = contact.displayName
        contactCell?.statusImageView.image = UIImage(named: contact.status)
        let contactSelector = selector as? ContactCellSelector
        contactSelector?.contactCell = contactCell
        
    }

    deinit {

        NotificationCenter.default.removeObserver(self, name: Notifications.PendingContactsUpdated,
                                                  object: nil)

    }

    @objc func pendingContactsUpdated(_ notification: Notification) {

        if let contacts = notification.object as? [Contact] {
            for updated in contacts {
                if updated.publicId == contact.publicId {
                    DispatchQueue.main.async {
                        self.contactCell?.statusImageView.image = UIImage.init(named: updated.status)
                    }
                    contact = updated
                }
            }
        }

    }

}

class ContactCellSelector: ExpandingTableSelectorProtocol {

    var viewController: UIViewController?
    var tableView: ExpandingTableView?
    var contact: Contact
    var contactCell: ContactCell?

    init(contact: Contact) {

        self.contact = contact

    }

    func didSelect(_ indexPath: IndexPath) {
        
        if contactCell!.isExpanded() {
            contactCell!.close()
            tableView?.collapseRow(at: indexPath)
        }
        else {
            contactCell!.open()
            var cells = [ CellDataProtocol ]()
            cells.append(ContactPublicIdData(publicId: contact.publicId))
            cells.append(LastSeenCellData(contact: contact))
            let deleteData = DeleteContactData()
            let deleteSelector = DeleteContactSelector(contact.publicId)
            deleteSelector.viewController = viewController
            deleteSelector.tableView = tableView
            deleteData.selector = deleteSelector
            cells.append(deleteData)
            tableView?.expandRow(at: indexPath, cells: cells)
        }
    }
    
}
