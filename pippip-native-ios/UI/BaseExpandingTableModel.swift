//
//  BaseExpandingTableModel.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/6/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class BaseExpandingTableModel: NSObject, ExpandingTableModelProtocol {

    var tableView: ExpandingTableView!
    var headerViews = [Int : ViewDataProtocol]()
    var expandingCells = [Int: [ExpandingTableViewCell]]()
    
    func appendChildren(cells: [ExpandingTableCell], indexPath: IndexPath) {

        let row = translateRow(indexPath)
        let cell = expandingCells[indexPath.section]![row]
        var childRow = cell.children?.count ?? 0
        if cell.children != nil {
            cell.children?.append(contentsOf: cells)
        }
        else {
            childRow = cell.children!.count
            cell.children = cells
        }
        if cell.isOpen {
            var paths = [IndexPath]()
            for index in 0..<cells.count {
                paths.append(IndexPath(row: index+childRow + 1, section: indexPath.section))
            }
            tableView.insertRows(at: paths, with: .top)
        }
    
    }
    
    func appendChildren(cells: [ExpandingTableCell], parent: ExpandingTableViewCell) {

        guard let path = getPath(cell: parent) else { return }
        appendChildren(cells: cells, indexPath: path)

    }

    func appendExpandingCell(cell: ExpandingTableViewCell, section: Int, animation: UITableViewRowAnimation) {

        if expandingCells[section] == nil {
            expandingCells[section] = [ExpandingTableViewCell]()
        }
        let row = max(expandingCells[section]!.count - 1, 0)
        expandingCells[section]?.append(cell)
        var paths = [IndexPath]()
        paths.append(IndexPath(row: row, section: section))
        // Add the child cells, if any
        if cell.isOpen && cell.children != nil {
            for childRow in 0..<cell.children!.count {
                paths.append(IndexPath(row: row+childRow, section: section))
            }
        }
        tableView.insertRows(at: paths, with: animation)
        
    }
    
    func appendExpandingCells(cells: [ExpandingTableViewCell], section: Int, animation: UITableViewRowAnimation) {

        if expandingCells[section] == nil {
            expandingCells[section] = [ExpandingTableViewCell]()
        }
        let row = max(expandingCells[section]!.count - 1, 0)
        expandingCells[section]?.append(contentsOf: cells)
        var paths = [IndexPath]()
        var children = 0
        for expanding in 0..<cells.count {
            let cell = cells[expanding]
            paths.append(IndexPath(row: row+children+expanding, section: section))
            // Add the child cells, if any
            if cell.isOpen && cell.children != nil {
                for childRow in 0..<cell.children!.count {
                    paths.append(IndexPath(row: row+expanding+childRow+children, section: section))
                }
                children = children + cell.children!.count
            }
        }
        tableView.insertRows(at: paths, with: animation)
        
    }

    func clear(section: Int) {

        assert(Thread.isMainThread)
        expandingCells[section]?.removeAll()
        tableView.reloadData()
        
    }

    func collapseAll() {

        assert(Thread.isMainThread)
        for section in expandingCells.keys {
            if let cells = expandingCells[section] {
                for cell in cells {
                    cell.close()
                }
            }
        }
        self.tableView.reloadData()

    }

    func collapseCell(indexPath: IndexPath) {

        assert(Thread.isMainThread, "collapseCell must be called from the main thread")
        let actual = translateRow(indexPath)
        let cell = expandingCells[indexPath.section]?[actual]
        assert(cell != nil)
        cell?.close()
        if cell!.children!.count > 0 {
            var paths = [IndexPath]()
            for row in 0..<cell!.children!.count {
                paths.append(IndexPath(row: indexPath.row+row+1, section: indexPath.section))
            }
            self.tableView.deleteRows(at: paths, with: .top)
        }

    }

    func createCells(cellIds: [String]) -> [ExpandingTableCell] {
        
        var cells = [ExpandingTableCell]()
        for cellId in cellIds {
            if let cell = self.tableView.dequeueReusableCell(withIdentifier: cellId) as? ExpandingTableCell {
                cell.configure()
                cells.append(cell)
            }
        }
        return cells
        
    }
    
    func createCells(cellId: String, count: Int) -> [ExpandingTableCell] {
        
        var cells = [ExpandingTableCell]()
        while cells.count < count {
            guard let cell = self.tableView.dequeueReusableCell(withIdentifier: cellId) as? ExpandingTableCell
                else { return [ExpandingTableCell]() }
            cell.configure()
            cells.append(cell)
        }
        return cells
        
    }
    
    func expandCell(indexPath: IndexPath, children: [ExpandingTableCell]?) {

        assert(Thread.isMainThread, "expandCell must be called from the main thread")
        let actual = translateRow(indexPath)
        guard let cell = expandingCells[indexPath.section]?[actual] else { return }
        if cell.children == nil || children != nil {
            cell.children = children
        }
        assert(cell.children != nil)
        cell.open()
        var paths = [IndexPath]()
        let count = cell.children?.count ?? 0
        for row in 0..<count {
            paths.append(IndexPath(row: indexPath.row+row+1, section: indexPath.section))
        }
        self.tableView.insertRows(at: paths, with: .top)

    }

    // This will be called after cells are inserted
    func getCell(indexPath: IndexPath) -> UITableViewCell {

        assert(Thread.isMainThread)
        guard let cells = expandingCells[indexPath.section] else { return UITableViewCell() }
        var childCount = 0
        for expanding in 0..<cells.count {
            let cell = cells[expanding]
            if expanding + childCount == indexPath.row {
                // Expanding cell
                return cell
            }
            else if cell.isOpen && cell.children != nil {
                for childIndex in 0..<cell.children!.count {
                    if expanding + childCount + childIndex + 1 == indexPath.row {
                        return cell.children![childIndex]
                    }
                }
                childCount = childCount + cell.children!.count
            }
        }
        return UITableViewCell()
        
    }

    func getCells(cellIds: [String]) -> [ExpandingTableCell] {

        var cells = [ExpandingTableCell]()
        for cellId in cellIds {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? ExpandingTableCell else {
                assert(false, "Invalid table cell type")
            }
            cell.configure()
            cells.append(cell)
        }
        return cells

    }

    func getChildren(indexPath: IndexPath) -> [ExpandingTableCell]? {

        let row = translateRow(indexPath)
        guard let cell = expandingCells[indexPath.section]?[row] else { return nil }
        return cell.children

    }

    func getPath(cell: ExpandingTableViewCell) -> IndexPath? {

        for section in expandingCells.keys {
            for item in 0..<expandingCells[section]!.count {
                if cell == expandingCells[section]![item] {
                    return IndexPath(row: item, section: section)
                }
            }
        }
        return nil

    }

    func getRowCount(section: Int) -> Int {

        if expandingCells[section] != nil {
            var count = expandingCells[section]!.count
            for cell in expandingCells[section]! {
                if cell.isOpen && cell.children != nil {
                    count = count + cell.children!.count
                }
            }
            return count
        }
        else {
            return 0
        }

    }

    func removeExpandingCell(section: Int, row: Int, animation: UITableViewRowAnimation) {

        guard let cells = expandingCells[section] else { return }
        let cell = cells[row]
        var paths = [IndexPath]()
        let translated = translateRow(IndexPath(row: row, section: section))
        paths.append(IndexPath(row: row, section: section))
        if cell.isOpen && cell.children != nil {
            for child in 0..<cell.children!.count {
                paths.append(IndexPath(row: row+child, section: section))
            }
        }
        expandingCells[section]!.remove(at: translated)
        tableView.deleteRows(at: paths, with: animation)
        
    }

    func removeChild(indexPath: IndexPath, index: Int) {

        assert(Thread.isMainThread)
        let row = translateRow(indexPath)
        guard let cell = expandingCells[indexPath.section]?[row] else { return }
        assert(cell.children != nil)
        cell.children?.remove(at: index)
        if cell.isOpen {
            tableView.deleteRows(at: [IndexPath(row: row+index+1, section: indexPath.section)], with: .left)
        }

    }

    // Translates a table row to an expanding cell row
    func translateRow(_ indexPath: IndexPath) -> Int {
        
        guard let cells = expandingCells[indexPath.section] else { return 0 }
        var childCount = 0
        for expanding in 0..<cells.count {
            if expanding + childCount == indexPath.row {
                return expanding
            }
            else {
                let cell = cells[expanding]
                if cell.isOpen && cell.children != nil {
                    childCount = childCount + cell.children!.count
                }
            }
        }
        assert(false, "Index path is invalid")
        
    }

    // Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {

        return expandingCells.count

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return getRowCount(section: section)

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        return getCell(indexPath: indexPath)

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        guard let cell = getCell(indexPath: indexPath) as? ExpandingTableViewCell else { return 0.0 }
        return cell.cellHeight

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

        guard let cell = getCell(indexPath: indexPath) as? ExpandingTableViewCell else { return }
        cell.selector?.didSelect(indexPath: indexPath, cell: cell)

    }

}
