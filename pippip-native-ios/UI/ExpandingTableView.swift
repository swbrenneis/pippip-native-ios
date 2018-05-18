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

    var expandedCounts = [IndexPath: Int]()

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */


    func expandRow(at indexPath: IndexPath, cells: [ CellDataProtocol ]) {

        expandingModel?.insertCells(cellData: cells, section: indexPath.section, at: indexPath.item+1, with: .bottom)
        expandedCounts[indexPath] = cells.count

    }

    func collapseRow(at indexPath: IndexPath) {

        if let cell = cellForRow(at: indexPath) as? ExpandingTableViewCell {
            cell.close()
        }
        guard let count = expandedCounts[indexPath] else { return }
        if count == 1 {
            expandingModel?.removeCell(section: indexPath.section, row: indexPath.item+1, with: .top)
        }
        else {
            expandingModel?.removeCells(section: indexPath.section, row: indexPath.item+1, count: count, with: .top)
        }

    }

}
