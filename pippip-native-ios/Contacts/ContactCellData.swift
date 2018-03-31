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
    
    init(contactCell: ContactCell, contact: [AnyHashable: Any], viewController: ContactsViewController) {
        
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
    var contact: [AnyHashable: Any]
    var lastSeenFormatter: DateFormatter

    init(_ contact: [AnyHashable: Any], viewController: ContactsViewController) {
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
            let publicId = contact[AnyHashable("publicId")] as? String
            publicIdCell?.publicIdLabel.text = publicId
            cells.append(ContactPublicIdData(contactPublicIdCell: publicIdCell!, tableView: tableView!))
            // Last seen cell
            let lastSeenCell = tableView?.dequeueReusableCell(withIdentifier: "LastSeenCell") as? LastSeenCell
            let ts = contact[AnyHashable("timestamp")] as? NSNumber
            let timestamp = ts?.doubleValue ?? 0.0
            if (timestamp == 0) {
                lastSeenCell?.lastSeenLabel.text = "Never"
            }
            else {
                let tsDate = Date.init(timeIntervalSince1970: timestamp)
                lastSeenCell?.lastSeenLabel.text = lastSeenFormatter.string(from: tsDate)
            }
            cells.append(LastSeenCellData(contactCell: lastSeenCell!, tableView: tableView!))
            // Delete contact cell
            cells.append(DeleteContactData(publicId: publicId!, viewController: viewController!))
            tableView?.expandRow(at: indexPath, cells: cells)
        }
    }
    
}
