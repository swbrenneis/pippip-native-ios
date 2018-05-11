//
//  PendingContactsCellData.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class PendingRequestsCellData: NSObject, CellDataProtocol {

    var cellId: String = "PendingRequestsCell"
    var cellHeight: CGFloat = 50.0
    var selector: ExpandingTableSelectorProtocol?
    var userData: [String: Any]?

    func updateRequests(requests: [ContactRequest]) {

        let pendingSelector = selector as? PendingRequestsSelector
        pendingSelector?.updateRequests(requests: requests)

    }

    func configureCell(_ cell: UITableViewCell) {

        let pendingSelector = selector as? PendingRequestsSelector
        pendingSelector?.cell = cell as? ExpandingTableViewCell

    }
    
}

class PendingRequestsSelector: ExpandingTableSelectorProtocol {

    var viewController: UIViewController?
    var tableView: ExpandingTableView?
    var cell: ExpandingTableViewCell?
    var requests: [ContactRequest]

    init(requests: [ContactRequest]) {

        self.requests = requests

    }

    func didSelect(_ indexPath: IndexPath) {

        cell!.setSelected(false, animated: true)
        if cell!.isExpanded() {
            cell!.close()
            tableView?.collapseRow(at: indexPath)
        }
        else {
            cell!.open()
            var cells = [CellDataProtocol]()
            for request in requests {
                let pendingData = PendingRequestCellData(contactRequest: request)
                let pendingSelector = PendingRequestSelector(contactRequest: request)
                pendingSelector.viewController = self.viewController
                pendingSelector.tableView = self.tableView
                pendingData.selector = pendingSelector
                cells.append(pendingData)
            }
            tableView?.expandRow(at: indexPath, cells: cells)
        }

    }

    func updateRequests(requests: [ContactRequest]) {

        if cell!.isExpanded() {
            DispatchQueue.main.async {
                self.tableView?.expandingModel!.removeCells(section: 0, row: 1, count: requests.count,
                                                            with: .left)
            }
        }
        self.requests = requests
        if cell!.isExpanded() {
            DispatchQueue.main.async {
                var cells = [CellDataProtocol]()
                for request in requests {
                    let pendingData = PendingRequestCellData(contactRequest: request)
                    let pendingSelector = PendingRequestSelector(contactRequest: request)
                    pendingSelector.viewController = self.viewController
                    pendingSelector.tableView = self.tableView
                    pendingData.selector = pendingSelector
                    cells.append(pendingData)
                }
                self.tableView?.expandingModel?.insertCells(cellData: cells, section: 0, at: 1, with: .right)
            }
        }
        
    }

}

