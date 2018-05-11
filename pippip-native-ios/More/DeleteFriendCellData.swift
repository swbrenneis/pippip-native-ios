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

class DeleteFriendCellData: NSObject, CellDataProtocol {

    var cellId: String = "DeleteFriendCell"
    var cellHeight: CGFloat = 50.0
    var selector: ExpandingTableSelectorProtocol?
    var userData: [String : Any]?

    func configureCell(_ cell: UITableViewCell) {
        // noop
    }

}

class DeleteFriendSelector: ExpandingTableSelectorProtocol {

    var viewController: UIViewController?
    var tableView: ExpandingTableView?
    var contactManager = ContactManager()
    var config = Configurator()
    var publicId: String
    var friendPath: IndexPath?

    init(publicId: String) {

        self.publicId = publicId

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
            self.tableView?.collapseRow(at: self.friendPath!)
            self.tableView?.expandingModel?.removeCell(section: self.friendPath!.section,
                                                       row: self.friendPath!.row, with: .left)
        }

    }

}

