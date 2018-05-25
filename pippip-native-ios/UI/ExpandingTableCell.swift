//
//  ExpandingTableCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/21/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ExpandingTableCell: PippipTableViewCell {

    var selector: ExpandingTableCellSelectorProtocol?

    func configure() {
        
    }
    
}
class NoopSelector: ExpandingTableCellSelectorProtocol {
    
    var viewController: UIViewController?
    var tableView: ExpandingTableView?
    
    func didSelect(indexPath: IndexPath, cell: UITableViewCell) {
        // noop
    }
    
}
