//
//  ContactsTableModel.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/31/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ContactsHeaderView: ViewDataProtocol {
    
    var view: UIView
    var height: CGFloat
    
    init(_ frame: CGRect) {
        view = UIView(frame: frame)
        view.backgroundColor = .clear
        height = 20.0
    }
    
}

class ContactsTableModel: BaseExpandingTableModel {

    var viewController: ContactsViewController?

    override init() {

        super.init()

        expandingCells[0] = [ExpandingTableViewCell]()
        expandingCells[1] = [ExpandingTableViewCell]()
        
   }

    func setContacts(contactList: [Contact], viewController: ContactsViewController) {

        clear(section: 1)
        if !contactList.isEmpty {
            guard let cells = createCells(cellId: "ContactCell", count: contactList.count) as? [ExpandingTableViewCell]
                else { return }
            for index in 0..<cells.count {
                let cell = cells[index] as! ContactCell
                let contact = contactList[index]
                cell.contact = contact
                cell.setMediumTheme()
                addChildren(cell: cell, contact: contact)
                let cellSelector = ContactCellSelector(contact: contact)
                cellSelector.tableView = viewController.tableView
                cellSelector.viewController = viewController
                cell.selector = cellSelector
            }
            appendExpandingCells(cells: cells, section: 1, animation: .bottom)
        }

    }
    
    func addChildren(cell: ContactCell, contact: Contact) {

        var cellIds = ["ContactPublicIdCell", "LastSeenCell"]
        if contact.status == "pending" {
            cellIds.append("RetryRequestCell")
        }
        cellIds.append("DeleteContactCell")
        let cells = createCells(cellIds: cellIds)
        guard let publicIdCell = cells[0] as? ContactPublicIdCell else { return }
        publicIdCell.publicIdLabel.text = contact.publicId
        guard let lastSeenCell = cells[1] as? LastSeenCell else { return }
        lastSeenCell.setLastSeen(timestamp: contact.timestamp)
        if contact.status == "pending" {
            cells[2].setLightTheme()
            let retryRequestSelector = RetryRequestSelector(publicId: contact.publicId)
            retryRequestSelector.tableView = tableView
            cells[2].selector = retryRequestSelector
            cells[3].setLightTheme()
            let deleteContactSelector = DeleteContactSelector(publicId: contact.publicId, status: contact.status)
            deleteContactSelector.tableView = tableView
            deleteContactSelector.viewController = viewController
            cells[3].selector = deleteContactSelector
        }
        else {
            cells[2].setLightTheme()
            let deleteContactSelector = DeleteContactSelector(publicId: contact.publicId, status: contact.status)
            deleteContactSelector.tableView = tableView
            deleteContactSelector.viewController = viewController
            cells[2].selector = deleteContactSelector
        }
        cell.children = cells

    }

    func setPendingRequests(pendingRequests: [ContactRequest], viewController: ContactsViewController) {
        
        viewController.contactsModel.clear(section: 0)
        let cells = viewController.contactsModel.createCells(cellId: "PendingRequestsCell", count: 1)
        let cell = cells[0] as! ExpandingTableViewCell
        cell.setDarkTheme()
        let pendingCellSelector = PendingRequestsSelector(requests: Set(pendingRequests))
        pendingCellSelector.tableView = viewController.tableView
        pendingCellSelector.viewController = viewController
        cell.selector = pendingCellSelector
        appendExpandingCell(cell: cell, section: 0, animation: .right)
        
    }
    
}
