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

class DeleteFriendSelector: ExpandingTableCellSelectorProtocol {

    var viewController: UIViewController?
    var tableView: ExpandingTableView?
    var contactManager = ContactManager()
    var config = Configurator()
    var publicId: String
    var friendPath: IndexPath!
    var alertPresenter = AlertPresenter()

    init(publicId: String) {

        self.publicId = publicId

    }

    func didSelect(indexPath: IndexPath, cell: UITableViewCell) {

        NotificationCenter.default.addObserver(self, selector: #selector(friendDeleted(_:)),
                                               name: Notifications.FriendDeleted, object: nil)
        
        friendPath = IndexPath(row: indexPath.row-1, section: indexPath.section)
        contactManager.deleteFriend(publicId)

    }

    @objc func friendDeleted(_ : Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.FriendDeleted, object: nil)
        config.deleteWhitelistEntry(publicId)
        self.alertPresenter.successAlert(title: "Friend Deleted",
                                         message: "This friend has been removed from your friends list")
        DispatchQueue.main.async {
            self.tableView?.expandingModel?.removeExpandingCell(section: self.friendPath.section,
                                                                row: self.friendPath.row, animation: .left)
        }

    }

}

