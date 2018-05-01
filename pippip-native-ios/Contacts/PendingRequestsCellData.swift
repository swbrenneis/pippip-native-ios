//
//  PendingContactsCellData.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class PendingRequestsCellData: CellDataProtocol {

    var cell: UITableViewCell
    var cellHeight: CGFloat
    var selector: ExpandingTableSelectorProtocol
    var userData: [String: Any]?
    
    init(_ requests: [[AnyHashable:Any]], viewController: ContactsViewController) {

        let pendingCell =
            viewController.tableView.dequeueReusableCell(withIdentifier: "PendingRequestsCell") as! ExpandingTableViewCell
        cell = pendingCell
        cellHeight = 50.0
        let requestsSelector = PendingRequestsSelector(pendingCell, requests: requests, viewController: viewController)
        selector = requestsSelector
        
    }

    func updateRequests(_ requests: [[AnyHashable: Any]]) {

        let pendingSelector = selector as! PendingRequestsSelector
        pendingSelector.updateRequests(requests)

    }

}

class PendingRequestsSelector: ExpandingTableSelectorProtocol {

    weak var cell: ExpandingTableViewCell?
    weak var viewController: ContactsViewController?
    var requests: [[AnyHashable:Any]]

    init(_ cell: ExpandingTableViewCell, requests: [[AnyHashable:Any]], viewController: ContactsViewController) {

        self.cell = cell
        self.requests = requests
        self.viewController = viewController

    }

    func didSelect(_ indexPath: IndexPath) {

        cell!.setSelected(false, animated: true)
        let tableView = viewController!.tableView!
        if cell!.isExpanded() {
            cell!.close()
            let _ = tableView.expandingModel!.removeCells(section: 0, row: 1, count: requests.count)
            tableView.deleteRows(at: tableView.expandingModel!.deletePaths, with: .top)
        }
        else {
            cell!.open()
            var cells = [CellDataProtocol]()
            for request in requests {
                cells.append(PendingRequestCellData(request, viewController: viewController))
            }
            tableView.expandingModel?.insertCells(cells, section: 0, at: 1)
            tableView.insertRows(at: tableView.expandingModel!.insertPaths, with: .bottom)
        }

    }

    func updateRequests(_ requests: [[AnyHashable: Any]]) {

        let tableView = viewController!.tableView!
        if cell!.isExpanded() {
            DispatchQueue.main.async {
                let _ = tableView.expandingModel!.removeCells(section: 0, row: 1, count: requests.count)
                tableView.deleteRows(at: tableView.expandingModel!.deletePaths, with: .top)
            }
        }
        self.requests = requests
        if cell!.isExpanded() {
            DispatchQueue.main.async {
                var cells = [CellDataProtocol]()
                for request in requests {
                    cells.append(PendingRequestCellData(request, viewController: self.viewController))
                }
                tableView.expandingModel?.insertCells(cells, section: 0, at: 1)
                tableView.insertRows(at: tableView.expandingModel!.insertPaths, with: .bottom)
            }
        }
        
    }

}

