//
//  BaseExpandingTableModel.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/6/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class BaseExpandingTableModel: ExpandingTableModelProtocol {

    var tableModel: [Int : [CellDataProtocol]]
    var headerViews: [Int : ViewDataProtocol]
    var insertPaths: [IndexPath]
    var deletePaths: [IndexPath]
    
    init() {

        tableModel = [0 : [CellDataProtocol]()]
        headerViews = [ Int: ViewDataProtocol ]()
        insertPaths = [ IndexPath ]()
        deletePaths = [ IndexPath ]()

    }

    func clear(_ section: Int, tableView: UITableView) {

        if tableModel[section] != nil {
            while tableModel[section]!.count > 0 {
                let _ = removeCell(section: section, row: 0)
                tableView.deleteRows(at: deletePaths, with: .top)
            }
        }
        
    }
    
    func appendCell(_ cell: CellDataProtocol, section: Int) {
        
        if tableModel[section] == nil {
            tableModel[section] = [ cell ]
        }
        else {
            tableModel[section]?.append(cell)
        }
        insertPaths = [ IndexPath(row: tableModel[section]!.count-1, section: section)]
        
    }

    /*
     * Get cells from row to row + count, inclusive. If count = 0
     * get cells from row to end of section, inclusive
     */
    func getCells(section: Int, row: Int, count: Int) -> [CellDataProtocol] {
        
        var cells = [CellDataProtocol]()
        var rowCount = count
        if count == 0 || row + count > tableModel[section]!.count {
            rowCount = tableModel[section]!.count - row
        }
        for index in 0..<rowCount {
            cells.append(tableModel[section]![row + index])
        }
        return cells
        
    }
    
    func insertCell(_ cell: CellDataProtocol, section: Int, row: Int) {
        
        if tableModel[section] == nil {
            tableModel[section] = [ cell ]
        }
        else if row >= tableModel[section]!.count {
            tableModel[section]!.append(cell)
        }
        else {
            var newCells = [ CellDataProtocol ]()
            for i in 0..<tableModel[section]!.count {
                if i != row {
                    newCells.append(tableModel[section]![i])
                }
                else {
                    newCells.append(cell)
                }
            }
            tableModel[section] = newCells
        }
        insertPaths = [ IndexPath(row: row, section: section) ]
        
    }
    
    func insertCells(_ cells: [CellDataProtocol], section: Int, at: Int) {
        
        if tableModel[section] == nil {
            tableModel[section] = cells
        }
        else if (at >= tableModel[section]!.count) {
            tableModel[section]?.append(contentsOf: cells)
        }
        else {
            var newCells = [ CellDataProtocol ]()
            for i in 0..<tableModel[section]!.count {
                if i == at {
                    newCells.append(contentsOf: cells)
                }
                newCells.append(tableModel[section]![i])
            }
            tableModel[section] = newCells
        }
        insertPaths = [ IndexPath ]()
        for i in 0..<cells.count {
            insertPaths.append(IndexPath(row: at+i, section: section))
        }
        
    }
    
    func removeCell(section: Int, row: Int) -> CellDataProtocol? {
        
        if tableModel[section] == nil {
            return nil
        }
        else {
            var deleted: CellDataProtocol?
            var newCells = [ CellDataProtocol ]()
            for i in 0..<tableModel[section]!.count {
                if i != row {
                    newCells.append(tableModel[section]![i])
                }
                else {
                    deleted = tableModel[section]![i]
                }
            }
            tableModel[section] = newCells
            deletePaths = [ IndexPath(row: row, section: section) ]
            return deleted
        }
        
    }
    
    func removeCells(section: Int, row: Int, count: Int) -> [CellDataProtocol]? {
        
        if tableModel[section] == nil {
            return nil
        }
        else {
            deletePaths = [ IndexPath ]()
            var deleted = [ CellDataProtocol ]()
            var newCells = [ CellDataProtocol ]()
            let end = row + count
            for i in 0..<tableModel[section]!.count {
                if i < row || i >= end {
                    newCells.append(tableModel[section]![i])
                }
                else {
                    deleted.append(tableModel[section]![i])
                    deletePaths.append(IndexPath(row: i, section: section))
                }
            }
            tableModel[section] = newCells
            return deleted
        }
        
    }
    
}
