//
//  ContactCellData.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/31/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ContactCellData: CellDataProtocol {

    var cell: UITableViewCell
    var cellHeight: CGFloat
    var selector: ExpandingTableSelectorProtocol
    var userData: [String : Any]?
    
    init(contactCell: ContactCell, contact: Contact, viewController: ContactsViewController) {
        
        cell = contactCell
        cellHeight = ContactCell.cellHeight
        let contactSelector = ContactCellSelector(contact, viewController: viewController)
        contactSelector.contactCell = contactCell
        selector = contactSelector
        
    }
    
}

class ContactCellSelector: ExpandingTableSelectorProtocol {
    
    weak var viewController: ContactsViewController?
    weak var contactCell: ContactCell?
    weak var tableView: ExpandingTableView?
    var contact: Contact
    var lastSeenFormatter: DateFormatter

    init(_ contact: Contact, viewController: ContactsViewController) {
        self.contact = contact
        self.viewController = viewController
        self.tableView = viewController.tableView
        lastSeenFormatter = DateFormatter()
        lastSeenFormatter.dateFormat = "MMM dd YYYY hh:mm"
    }

    func didSelect(_ indexPath: IndexPath) {
        
        if contactCell!.isExpanded() {
            contactCell!.close()
            tableView?.collapseRow(at: indexPath, count: 3)
        }
        else {
            contactCell!.open()
            var cells = [ CellDataProtocol ]()
            // Public ID cell
            let publicIdCell =
                tableView?.dequeueReusableCell(withIdentifier: "ContactPublicIdCell") as? ContactPublicIdCell
            publicIdCell?.publicIdLabel.text = contact.publicId
            cells.append(ContactPublicIdData(contactPublicIdCell: publicIdCell!, tableView: tableView!))
            // Last seen cell
            let lastSeenCell = tableView?.dequeueReusableCell(withIdentifier: "LastSeenCell") as? LastSeenCell
            if (contact.timestamp == 0) {
                lastSeenCell?.lastSeenLabel.text = "Never"
            }
            else {
                let tsDate = Date.init(timeIntervalSince1970: TimeInterval(contact.timestamp))
                lastSeenCell?.lastSeenLabel.text = lastSeenFormatter.string(from: tsDate)
            }
            cells.append(LastSeenCellData(contactCell: lastSeenCell!, tableView: tableView!))
            // Delete contact cell
            cells.append(DeleteContactData(publicId: contact.publicId, viewController: viewController!))
            tableView?.expandRow(at: indexPath, cells: cells)
        }
    }
    
}
