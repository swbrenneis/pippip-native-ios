//
//  ExpandingTableModelProtocol.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/30/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

protocol CellDataProtocol {

    var cell: UITableViewCell { get set }
    var cellHeight: CGFloat { get set }
    var selector: ExpandingTableSelectorProtocol { get set }
    var userData: [ String: Any ]? { get set }

}

protocol ViewDataProtocol {

    var view: UIView { get set }
    var height: CGFloat { get set }

}

protocol ExpandingTableModelProtocol {

    var tableModel: [ Int: [ CellDataProtocol ] ] { get }
    
    var headerViews: [ Int: ViewDataProtocol ] { get }

    var insertPaths: [ IndexPath ] { get }
    
    var deletePaths: [ IndexPath ] { get }

    func clear(_ section: Int)

    func appendCell(_ cell: CellDataProtocol, section: Int)

    func insertCell(_ cell: CellDataProtocol, section: Int, row: Int)
    
    func insertCells(_ cells: [ CellDataProtocol ], section: Int, at: Int)
    
    func removeCell(section: Int, row: Int) -> CellDataProtocol?

    func removeCells(section: Int, row: Int, count: Int) -> [ CellDataProtocol ]?

}

