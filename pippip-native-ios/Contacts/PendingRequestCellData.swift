//
//  PendingRequestCellData.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import PMAlertController

class PendingRequestCellData: NSObject, CellDataProtocol {

    var cellId: String = "PendingRequestCell"
    var cellHeight: CGFloat = 65
    var selector: ExpandingTableSelectorProtocol?
    var userData: [String : Any]?
    var contactRequest: ContactRequest
/*
    init?(entity:[AnyHashable:Any]) {

        guard let req = ContactRequest(serverRequest: entity) else { return nil }
        contactRequest = req

    }
*/

    init(contactRequest: ContactRequest) {

        self.contactRequest = contactRequest

    }

    func configureCell(_ cell: UITableViewCell) {
        
        guard let pendingCell = cell as? PendingRequestCell else { return }
        pendingCell.nicknameLabel.text = contactRequest.nickname ?? ""
        pendingCell.publicIdLabel.text = contactRequest.publicId

    }
    
}

class PendingRequestSelector: ExpandingTableSelectorProtocol {

    var viewController: UIViewController?
    var tableView: ExpandingTableView?
    var contactRequest: ContactRequest
    var contactManager = ContactManager()
    var selectedPath: IndexPath?
/*
    init?(entity: [AnyHashable: Any]) {

        guard let req = ContactRequest(serverRequest: entity) else { return nil }
        contactRequest = req
        
    }
*/

    init(contactRequest: ContactRequest) {

        self.contactRequest = contactRequest

    }

    func didSelect(_ indexPath: IndexPath) {

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

        DispatchQueue.main.async {
            let requests = self.contactManager.pendingRequests
            if requests.count == 0 {
                self.tableView?.expandingModel?.clear(section: 0)
            }
            else {
                self.tableView?.collapseRow(at: self.selectedPath!)
                let cells = self.tableView?.expandingModel?.getCells(section: 0)
                var removed = false
                for item in 1..<cells!.count {
                    if !removed {
                        let requestCellData = cells![item] as! PendingRequestCellData
                        if !requests.contains(requestCellData.contactRequest) {
                            self.tableView?.expandingModel?.removeCell(section: 0, row: item, with: .left)
                            removed = true
                        }
                    }
                }
            }

            let contactList = self.contactManager.getContactList()
            let contact = contactList.last!
            if contact.status == "accepted" || contact.status == "rejected" {
                let cellData = ContactCellData(contact: contact)
                let cellSelector = ContactCellSelector(contact: contact)
                cellSelector.tableView = self.tableView
                cellSelector.viewController = self.viewController
                cellData.selector = cellSelector
                self.tableView?.expandingModel?.appendCell(cellData: cellData, section: 1, with: .right)
            }
        }

    }

}
