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
        view.backgroundColor = UIColor.flatWhiteDark
        height = 40.0
    }
    
}

class ContactsTableModel: BaseExpandingTableModel {

    override init() {

        super.init()
        tableModel[1] = [CellDataProtocol]()
        
    }

    func setContacts(contactList: [Contact], viewController: ContactsViewController) {

        tableModel[1]?.removeAll()
        if !contactList.isEmpty {
            var cells = [CellDataProtocol]()
            for contact in contactList {
                let cellData = ContactCellData(contact: contact)
                let cellSelector = ContactCellSelector(contact: contact)
                cellSelector.tableView = viewController.tableView
                cellSelector.viewController = viewController
                cellData.selector = cellSelector
                cells.append(cellData)
            }
            insertCells(cellData: cells, section: 1, at: 0, with: .top)
        }

    }

}
