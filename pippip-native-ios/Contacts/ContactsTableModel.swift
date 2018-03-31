//
//  ContactsTableModel.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/31/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ContactsHeaderView: ViewDataProtocol {
    
    var view: UIView
    var height: CGFloat
    
    init(_ frame: CGRect) {
        view = UIView(frame: frame)
        view.backgroundColor = UIColor(named: "Pale Gray")
        height = 40.0
    }
    
}

class ContactsTableModel: ExpandingTableModelProtocol {

    var tableModel: [Int : [CellDataProtocol]]
    var headerViews: [Int : ViewDataProtocol]
    var insertPaths: [IndexPath]
    var deletePaths: [IndexPath]
    weak var viewController: ContactsViewController?
    
    init(_ viewController: ContactsViewController) {
        
        self.viewController = viewController

        tableModel = [Int : [CellDataProtocol]]()
        tableModel = [ 1: [ NewContactCellData(viewController) ] ]
        let headerFrame = CGRect(x: 0.0, y:0.0, width: viewController.view.frame.size.width, height:40.0)
        headerViews = [ 1: ContactsHeaderView(headerFrame) ]
        insertPaths = [ IndexPath ]()
        deletePaths = [ IndexPath ]()
        
    }
    
    func clear() {
        
        tableModel.removeAll()
        headerViews.removeAll()
        insertPaths.removeAll()
        deletePaths.removeAll()
        
    }

    func appendCell(_ cell: CellDataProtocol, section: Int) {
        
        if tableModel[section] == nil {
            tableModel[section] = [ cell ]
        }
        else {
            tableModel[section]?.append(cell)
        }
        insertPaths = [ IndexPath(row: tableModel[section]!.count, section: section)]
        
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

    func setContacts(_ contactList: [ [ AnyHashable: Any] ], viewController: ContactsViewController) {

        var cells = [ CellDataProtocol ]()
        for contact in contactList {
            let tableView = viewController.tableView!
            let contactCell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
            if let nickname = contact[AnyHashable("nickname")] as? String {
                contactCell.identLabel.text = nickname
            }
            else if let publicId = contact[AnyHashable("publicId")] as? String {
                let fragment = publicId.prefix(10)
                contactCell.identLabel.text = String(fragment) + " ..."
            }
            else {
                contactCell.identLabel.text = ""
            }
            if let status = contact[AnyHashable("status")] as? String {
                contactCell.statusImageView.image = UIImage(named: status)
            }
            let cellData = ContactCellData(contactCell: contactCell,
                                           contact: contact, viewController: viewController)
            cells.append(cellData)
        }
        if cells.count > 0 {
            insertCells(cells, section: 0, at: 0)
        }

    }

}
