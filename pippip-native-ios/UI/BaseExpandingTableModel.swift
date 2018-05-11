//
//  BaseExpandingTableModel.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/6/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class BaseExpandingTableModel: NSObject, ExpandingTableModelProtocol {

    var tableView: UITableView!
    var tableModel: [Int : [CellDataProtocol]]
    var headerViews: [Int : ViewDataProtocol]
    
    override init() {

        tableModel = [0 : [CellDataProtocol]()]
        headerViews = [ Int: ViewDataProtocol ]()

        super.init()

    }

    func clear() {

        assert(Thread.isMainThread)
        for key in tableModel.keys {
            tableModel[key] = nil
        }
        tableView.reloadData()

    }

    func clear(section: Int) {

        assert(Thread.isMainThread)
        tableModel[section]?.removeAll()
        tableView.reloadData()
        
    }
    
    func appendCell(cellData: CellDataProtocol, section: Int, with: UITableViewRowAnimation) {
        
        assert(Thread.isMainThread)
        var indexPath = IndexPath(row: 0, section: section)
        if tableModel[section] == nil {
            tableModel[section] = [cellData]
            indexPath.row = 0
        }
        else {
            tableModel[section]!.append(cellData)
            indexPath.row = tableModel[section]!.count - 1
        }
        tableView.insertRows(at: [indexPath], with: with)
        
    }

    func appendCells(cellData: [CellDataProtocol], section: Int, with: UITableViewRowAnimation) {

        assert(Thread.isMainThread)
        var paths = [IndexPath]()
        let count = tableModel[section]?.count ?? 0
        for row in 0..<cellData.count {
            paths.append(IndexPath(row: count + row, section: section))
        }
        if tableModel[section] == nil {
            tableModel[section] = cellData
        }
        else {
            tableModel[section]?.append(contentsOf: cellData)
        }
        tableView.insertRows(at: paths, with: with)

    }

    func getCells(section: Int) -> [CellDataProtocol]? {

        return tableModel[section]
        
    }
    
    func insertCell(cellData: CellDataProtocol, section: Int, row: Int, with: UITableViewRowAnimation) {

        assert(Thread.isMainThread)
        assert(tableModel[section] != nil || row == 0)
        if tableModel[section] == nil {
            tableModel[section] = [cellData]
        }
        else if row >= tableModel[section]!.count {
            assert(false, "Attempt to insert cell beyond end of table")
        }
        else {
            var newCells = [ CellDataProtocol ]()
            for i in 0..<tableModel[section]!.count {
                if i != row {
                    newCells.append(tableModel[section]![i])
                }
                else {
                    newCells.append(cellData)
                }
            }
            tableModel[section] = newCells
        }
        tableView.insertRows(at: [IndexPath(row: row, section: section)], with: with)
        
    }
    
    func insertCells(cellData: [CellDataProtocol], section: Int, at: Int, with: UITableViewRowAnimation) {

        assert(Thread.isMainThread)
        if tableModel[section] == nil {
            tableModel[section] = cellData
        }
        else if (at > tableModel[section]!.count) {
            assert(false, "Attempt to insert cells beyond end of table")
        }
        else if at == tableModel[section]!.count {
            appendCells(cellData: cellData, section: section, with: with)
        }
        else {
            var insertPaths = [IndexPath]()
            for row in 0..<cellData.count {
                insertPaths.append(IndexPath(row: row + at, section: section))
            }
            let prefix = tableModel[section]![0..<at]
            let suffix = tableModel[section]![at..<tableModel[section]!.count]
            tableModel[section]!.removeAll()
            tableModel[section]!.append(contentsOf: prefix)
            tableModel[section]!.append(contentsOf: cellData)
            tableModel[section]!.append(contentsOf: suffix)
            tableView.insertRows(at: insertPaths, with: with)
        }
        
    }

    func removeCell(section: Int, row: Int, with: UITableViewRowAnimation) {

        assert(Thread.isMainThread)
        assert(tableModel[section]?[row] != nil)
        // var deleted: CellDataProtocol?
        var newCells = [CellDataProtocol]()
        for i in 0..<tableModel[section]!.count {
            if i != row {
                newCells.append(tableModel[section]![i])
            }
        }
        tableModel[section] = newCells
        tableView.deleteRows(at: [IndexPath(row: row, section: section)], with: with)
        
    }
    
    func removeCells(section: Int, row: Int, count: Int, with: UITableViewRowAnimation) {

        assert(Thread.isMainThread)
        assert(tableModel[section] != nil)
        assert(row + count <= tableModel[section]!.count, "Attempt to remove cells beyond the end of the table")
        var deletePaths = [IndexPath ]()
        var newCells = [CellDataProtocol]()
        let end = row + count
        for i in 0..<tableModel[section]!.count {
            if i < row || i >= end {
                newCells.append(tableModel[section]![i])
            }
            else {
                deletePaths.append(IndexPath(row: i, section: section))
            }
        }
        tableModel[section] = newCells
        tableView.deleteRows(at: deletePaths, with: with)

    }

    func numberOfSections(in tableView: UITableView) -> Int {

        return tableModel.keys.count

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return tableModel[section]!.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cellData = tableModel[indexPath.section]?[indexPath.row] else { assert(false, "Table view to table model row mismatch") }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellData.cellId, for: indexPath)
        cellData.configureCell(cell)
        return cell

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        guard let cellData = tableModel[indexPath.section]?[indexPath.row] else { assert(false, "Table view to table model row mismatch") }
        return cellData.cellHeight

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        return headerViews[section]?.view

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if let viewData = headerViews[section] {
            return viewData.height
        }
        else {
            return 0
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let cellData = tableModel[indexPath.section]?[indexPath.row] else { assert(false, "Table view to table model row mismatch") }
        cellData.selector?.didSelect(indexPath)

    }

}
