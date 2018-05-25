//
//  FriendCellData.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/30/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class FriendCellSelector: ExpandingTableCellSelectorProtocol {

    var viewController: UIViewController?
    var tableView: ExpandingTableView?

    func didSelect(indexPath: IndexPath, cell: UITableViewCell) {

        guard let friendCell = cell as? ExpandingTableViewCell else { return }
        if friendCell.isOpen {
            tableView?.collapseRow(at: indexPath)
        }
        else {
            tableView?.expandRow(at: indexPath, cells: nil)
        }

    }
    
}

