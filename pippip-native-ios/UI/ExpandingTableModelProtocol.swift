//
//  ExpandingTableModelProtocol.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/30/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

protocol CellDataProtocol {

    var cellHeight: CGFloat { get set }
    var cellId: String { get set }
    var selector: ExpandingTableSelectorProtocol? { get set }
    var userData: [ String: Any ]? { get set }

    func configureCell(_ cell: UITableViewCell);

}

protocol ViewDataProtocol {

    var view: UIView { get set }
    var height: CGFloat { get set }

}

protocol ExpandingTableModelProtocol: UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView! { get set }
    var tableModel: [ Int: [ CellDataProtocol ] ] { get }
    var headerViews: [ Int: ViewDataProtocol ] { get }

    func appendCell(cellData: CellDataProtocol, section: Int, with: UITableViewRowAnimation)
    
    func appendCells(cellData: [CellDataProtocol], section: Int, with: UITableViewRowAnimation);

    func clear()

    func clear(section: Int)

    func getCells(section: Int) -> [CellDataProtocol]?

    func insertCell(cellData: CellDataProtocol, section: Int, row: Int, with: UITableViewRowAnimation)
    
    func insertCells(cellData: [CellDataProtocol], section: Int, at: Int, with: UITableViewRowAnimation)

    //@discardableResult
    func removeCell(section: Int, row: Int, with: UITableViewRowAnimation) // -> CellDataProtocol?

    //@discardableResult
    func removeCells(section: Int, row: Int, count: Int, with: UITableViewRowAnimation) // -> [ CellDataProtocol ]?

}

