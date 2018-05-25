//
//  ExpandingTableModelProtocol.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/30/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

protocol ViewDataProtocol {

    var view: UIView { get set }
    var height: CGFloat { get set }

}

protocol ExpandingTableCellSelectorProtocol {
    
    var viewController: UIViewController? { get set }
    var tableView: ExpandingTableView? { get set }
    
    func didSelect(indexPath: IndexPath, cell: UITableViewCell)
    
}

protocol ExpandingTableModelProtocol: UITableViewDelegate, UITableViewDataSource {

    var tableView: ExpandingTableView! { get set }
    var headerViews: [ Int: ViewDataProtocol ] { get }

    func appendChildren(cells: [ExpandingTableCell], indexPath: IndexPath)
    
    func appendChildren(cells: [ExpandingTableCell], parent: ExpandingTableViewCell)
    
    func appendExpandingCell(cell: ExpandingTableViewCell, section: Int, animation: UITableViewRowAnimation)
    
    func appendExpandingCells(cells: [ExpandingTableViewCell], section: Int, animation: UITableViewRowAnimation)

    func clear(section: Int)

    func collapseAll()

    func collapseCell(indexPath: IndexPath)

    func createCells(cellIds: [String]) -> [ExpandingTableCell]
    
    func createCells(cellId: String, count: Int) -> [ExpandingTableCell]

    func expandCell(indexPath: IndexPath, children: [ExpandingTableCell]?)

    func getCell(indexPath: IndexPath) -> UITableViewCell
    
    func getChildren(indexPath: IndexPath) -> [ExpandingTableCell]?

    func removeChild(indexPath: IndexPath, index: Int)

    func removeExpandingCell(section: Int, row: Int, animation: UITableViewRowAnimation)

}

