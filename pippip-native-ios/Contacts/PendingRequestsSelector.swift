//
//  PendingContactsCellData.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class PendingRequestsSelector: ExpandingTableCellSelectorProtocol {

    var viewController: UIViewController?
    var tableView: ExpandingTableView?
    var requests: Set<ContactRequest>!
    var expandingCell: ExpandingTableViewCell!

    init(requests: Set<ContactRequest>) {

        self.requests = requests

    }

    func didSelect(indexPath: IndexPath, cell: UITableViewCell) {

        guard let ecell = cell as? ExpandingTableViewCell else { return }
        expandingCell = ecell
        expandingCell.setSelected(false, animated: true)
        if expandingCell.isOpen {
            tableView?.collapseRow(at: indexPath)
        }
        else {
            guard let expandingModel = tableView?.expandingModel else { return }
            if expandingModel.getChildren(indexPath: indexPath) == nil {
                // Create the new cells
                let cells = createChildren(requests: Array(requests))
                tableView?.expandingModel?.appendChildren(cells: cells, parent: expandingCell)
            }
            tableView?.expandRow(at: indexPath, cells: nil)
        }

    }

    func updateRequests(requests: [ContactRequest]) {

        // Add the new requests
        var newRequests = [ContactRequest]()
        for request in requests {
            if !requests.contains(request) {
                newRequests.append(request)
            }
        }
        assert(!newRequests.isEmpty)
        guard let tableModel = tableView?.expandingModel else { return }
        // Create the new cells
        let cells = createChildren(requests: requests)
        tableModel.appendChildren(cells: cells, parent: expandingCell)

    }

    func createChildren(requests: [ContactRequest]) -> [ExpandingTableCell] {
        
        let cells = tableView?.expandingModel?.createCells(cellId: "PendingRequestCell", count: requests.count)
        var index = 0
        for request in requests {
            let cell = cells![index] as! PendingRequestCell
            index = index + 1
            let pendingSelector = PendingRequestSelector(contactRequest: request)
            pendingSelector.viewController = self.viewController
            pendingSelector.tableView = self.tableView
            cell.selector = pendingSelector
        }
        return cells!

    }

}

