//
//  ContactCellData.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/31/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework

class ContactCellSelector: ExpandingTableCellSelectorProtocol {

    var viewController: UIViewController?
    var tableView: ExpandingTableView?
    var contact: Contact

    init(contact: Contact) {

        self.contact = contact

    }

    func didSelect(indexPath: IndexPath, cell: UITableViewCell) {

        guard let contactCell = cell as? ContactCell else { return }
        if contactCell.isOpen {
            tableView?.collapseRow(at: indexPath)
        }
        else {
            tableView?.expandRow(at: indexPath, cells: nil)
        }

    }
    
}
