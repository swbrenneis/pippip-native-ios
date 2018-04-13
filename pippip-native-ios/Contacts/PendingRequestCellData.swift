//
//  PendingRequestCellData.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import PMAlertController

class PendingRequestCellData: CellDataProtocol {

    var cell: UITableViewCell
    var cellHeight: CGFloat
    var selector: ExpandingTableSelectorProtocol
    var userData: [String : Any]?

    init(_ entity:[AnyHashable:Any], viewController: ContactsViewController?) {

        let pendingCell =
            viewController!.tableView.dequeueReusableCell(withIdentifier: "PendingRequestCell") as! PendingRequestCell
        let pendingSelector = PendingRequestSelector(viewController: viewController)
        if let nickname = entity[AnyHashable("nickname")] as? String {
            pendingCell.nicknameLabel.text = nickname
            pendingSelector.nickname = nickname
        }
        else {
            pendingCell.nicknameLabel.text = ""
        }
        if let publicId = entity[AnyHashable("publicId")] as? String {
            pendingCell.publicIdLabel.text = publicId
            pendingSelector.publicId = publicId
        }
        selector = pendingSelector
        cell = pendingCell
        cellHeight = 65.0

    }

}

class PendingRequestSelector: ExpandingTableSelectorProtocol {

    weak var viewController: ContactsViewController?
    var publicId = ""
    var nickname: String?
    var contactManager = ContactManager()

    init(viewController: ContactsViewController?) {
        self.viewController = viewController
    }

    func didSelect(_ indexPath: IndexPath) {

        NotificationCenter.default.addObserver(self, selector: #selector(requestAcknowledged(_:)),
                                               name: Notifications.RequestAcknowledged, object: nil)

        let name = nickname ?? publicId
        let alert = PMAlertController(title: "New Contact Request",
                                      description: "New contact request from \(name)",
                                      image: nil,
                                      style: PMAlertControllerStyle.alert)
        alert.addAction(PMAlertAction(title: "Accept",
                                      style: .default, action: { () in
                                        self.contactManager.acknowledgeRequest(response: "accept", publicId: self.publicId, nickname: self.nickname)
        }))
        alert.addAction(PMAlertAction(title: "Reject",
                                      style: .default, action: { () in
                                        self.contactManager.acknowledgeRequest(response: "reject", publicId: self.publicId, nickname: self.nickname)
        }))
        alert.addAction(PMAlertAction(title: "Delete",
                                      style: .default, action: { () in
                                        self.contactManager.acknowledgeRequest(response: "ignore", publicId: self.publicId, nickname: self.nickname)
        }))
        alert.addAction(PMAlertAction(title: "Cancel", style: .cancel))
        viewController?.present(alert, animated: true, completion: nil)

    }

    @objc func requestAcknowledged(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.RequestAcknowledged, object: nil)

        DispatchQueue.main.async {
            if let requests = notification.object as? [ [AnyHashable: Any] ] {
                if requests.count == 0 {
                    self.viewController!.contactsModel.clear(0, tableView: self.viewController!.tableView)
                }
                else {
                    // count = 0 means return all cells from row to end of second
                    let cells = self.viewController!.contactsModel.getCells(section: 0, row: 0, count: 0)
                    var item = 1
                    for cell in cells {
                        let requestCellData = cell as!PendingRequestCellData
                        let requestCell = requestCellData.cell as! PendingRequestCell
                        var found = false
                        for request in requests {
                            if request["publicId"] as? String == requestCell.publicIdLabel.text {
                                found = true
                            }
                        }
                        if !found {
                            let _ = self.viewController!.contactsModel.removeCell(section: 0, row: item)
                            self.viewController!.tableView.deleteRows(at: self.viewController!.contactsModel.deletePaths,
                                                                      with: .top)
                        }
                        item += 1
                    }
                }
            }

            let contactCell =
                self.viewController!.tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
            let contactList = self.contactManager.getContactList()
            let contact = contactList.last!
            contactCell.identLabel.text = contact.displayName
            let cellData = ContactCellData(contactCell: contactCell, contact: contact,
                                           viewController: self.viewController!)
            self.viewController!.contactsModel.appendCell(cellData, section: 1)
            self.viewController!.tableView.insertRows(at: self.viewController!.contactsModel.insertPaths,
                                                      with: .bottom)
        }

    }

}
