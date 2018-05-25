//
//  PendingRequestCellData.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import PMAlertController

class PendingRequestSelector: ExpandingTableCellSelectorProtocol {

    var viewController: UIViewController?
    var tableView: ExpandingTableView?
    var contactRequest: ContactRequest
    var contactManager = ContactManager()
    var selectedPath: IndexPath?

    init(contactRequest: ContactRequest) {

        self.contactRequest = contactRequest

    }

    func didSelect(indexPath: IndexPath, cell: UITableViewCell) {

        NotificationCenter.default.addObserver(self, selector: #selector(requestAcknowledged(_:)),
                                               name: Notifications.RequestAcknowledged, object: nil)

        selectedPath = indexPath
        let name = contactRequest.nickname ?? contactRequest.publicId

        let alert = PMAlertController(title: "New Contact Request",
                                      description: "New contact request from \(name)",
                                      image: nil,
                                      style: PMAlertControllerStyle.alert)
        alert.addAction(PMAlertAction(title: "Accept",
                                      style: .default, action: { () in
                                        self.contactManager.acknowledgeRequest(contactRequest: self.contactRequest,
                                                                               response: "accept")
        }))
        alert.addAction(PMAlertAction(title: "Reject",
                                      style: .default, action: { () in
                                        self.contactManager.acknowledgeRequest(contactRequest: self.contactRequest,
                                                                               response: "reject")
        }))
        alert.addAction(PMAlertAction(title: "Delete",
                                      style: .default, action: { () in
                                        self.contactManager.acknowledgeRequest(contactRequest: self.contactRequest,
                                                                               response: "ignore")
        }))
        alert.addAction(PMAlertAction(title: "Cancel", style: .cancel))
        viewController?.present(alert, animated: true, completion: nil)

    }

    @objc func requestAcknowledged(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.RequestAcknowledged, object: nil)

        guard let contact = notification.object as? Contact else { return }
        guard let contactsModel = tableView?.expandingModel as? ContactsTableModel else { return }
        let requests = self.contactManager.pendingRequests
        DispatchQueue.main.async {
            if requests.count == 0 {
                contactsModel.clear(section: 0)
            }
            else {
                let cells = self.tableView?.expandingModel?.getChildren(indexPath: self.selectedPath!)
                for item in 0..<cells!.count {
                    let requestCell = cells![item] as! PendingRequestCell
                    if requestCell.publicIdLabel.text == contact.publicId {
                        contactsModel.removeChild(indexPath: self.selectedPath!, index: item)
                    }
                }
            }

            if contact.status == "accepted" || contact.status == "rejected" {
                let cells = contactsModel.createCells(cellId: "ContactCell", count: 1)
                let contactCell = cells[0] as! ContactCell
                contactsModel.addChildren(cell: contactCell, contact: contact)
                contactsModel.appendExpandingCell(cell: contactCell, section: 1, animation: .top)
            }
        }

    }

}
