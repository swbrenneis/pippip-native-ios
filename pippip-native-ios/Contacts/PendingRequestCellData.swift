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
                                        self.contactManager.acknowledgeRequest("accept", withId: self.publicId, withNickname: self.nickname)
        }))
        alert.addAction(PMAlertAction(title: "Reject",
                                      style: .default, action: { () in
                                        self.contactManager.acknowledgeRequest("reject", withId: self.publicId, withNickname: self.nickname)
        }))
        alert.addAction(PMAlertAction(title: "Delete",
                                      style: .default, action: { () in
                                        self.contactManager.acknowledgeRequest("ignore", withId: self.publicId, withNickname: self.nickname)
        }))
        alert.addAction(PMAlertAction(title: "Cancel", style: .cancel))
        viewController?.present(alert, animated: true, completion: nil)

    }

    @objc func requestAcknowledged(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.RequestAcknowledged, object: nil)

        DispatchQueue.main.async {
            self.viewController!.contactsModel.clear(0, tableView: self.viewController!.tableView)
            if let requests = notification.object as? [ [AnyHashable: Any] ] {
                var cells = [CellDataProtocol]()
                for request in requests {
                    cells.append(PendingRequestCellData(request, viewController: self.viewController!))
                }
                self.viewController!.contactsModel.insertCells(cells, section: 0, at: 1)
                self.viewController!.tableView.insertRows(at: self.viewController!.contactsModel.insertPaths, with: .bottom)
            }
 
            self.viewController!.contactsModel.clear(1, tableView: self.viewController!.tableView)
            var paths = self.viewController!.contactsModel.deletePaths
            self.viewController!.tableView.deleteRows(at: paths, with: .top)
            let contactList = self.contactManager.getContactList()
            self.viewController!.contactsModel.setContacts(contactList)
            paths = self.viewController!.contactsModel.insertPaths
            self.viewController!.tableView.insertRows(at: paths, with: .bottom)
        }

    }

}
