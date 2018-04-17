//
//  DeleteFriendCellData.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/30/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import RKDropdownAlert
import ChameleonFramework

class DeleteFriendCellData: CellDataProtocol {

    var cell: UITableViewCell
    var cellHeight: CGFloat
    var selector: ExpandingTableSelectorProtocol
    var userData: [String : Any]?

    init(publicId: String, tableView: ExpandingTableView) {
        cell = tableView.dequeueReusableCell(withIdentifier: "DeleteFriendCell")!
        cellHeight = 50.0
        selector = DeleteFriendSelector(publicId, tableView: tableView)
    }

}

class DeleteFriendSelector: ExpandingTableSelectorProtocol {

    var contactManager = ContactManager()
    var config = Configurator()
    var publicId: String
    var tableView: ExpandingTableView
    var friendPath: IndexPath?

    init(_ publicId: String, tableView: ExpandingTableView) {

        self.publicId = publicId
        self.tableView = tableView

    }

    func didSelect(_ indexPath: IndexPath) {

        NotificationCenter.default.addObserver(self, selector: #selector(friendDeleted(_:)),
                                               name: Notifications.FriendDeleted, object: nil)
        
        friendPath = IndexPath(row: indexPath.row-1, section: indexPath.section)
        contactManager.deleteFriend(publicId)
    }

    @objc func friendDeleted(_ : Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.FriendDeleted, object: nil)
        config.deleteWhitelistEntry(publicId)
        DispatchQueue.main.async {
            let alertColor = UIColor.flatLime
            RKDropdownAlert.title("Friend Deleted", message: "This friend has been removed from your friends list",
                                  backgroundColor: alertColor,
                                  textColor: ContrastColorOf(alertColor, returnFlat: true),
                                  time: 2, delegate: nil)
            self.tableView.collapseRow(at: self.friendPath!, count: 1)
            if let model = self.tableView.expandingModel {
                let _ = model.removeCell(section: self.friendPath!.section, row: self.friendPath!.row)
                self.tableView.deleteRows(at: model.deletePaths, with: .right)
            }
        }

    }

}

