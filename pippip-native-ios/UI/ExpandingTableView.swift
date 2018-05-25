//
//  ExpandingTableView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ExpandingTableView: UITableView {

    var expandingModel: ExpandingTableModelProtocol? {
        didSet {
            expandingModel?.tableView = self
            self.delegate = expandingModel
            self.dataSource = expandingModel
        }
    }

    func collapseAll(section: Int) {


    }

    func expandRow(at indexPath: IndexPath, cells: [ExpandingTableCell]?) {

        expandingModel?.expandCell(indexPath: indexPath, children: cells)

    }

    func collapseRow(at indexPath: IndexPath) {

        expandingModel?.collapseCell(indexPath: indexPath)

    }

}
