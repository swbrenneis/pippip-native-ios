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

class ContactsTableModel: BaseExpandingTableModel {

    override init() {

        super.init()
        tableModel[1] = [CellDataProtocol]()
        
    }

    func setContacts(_ contactList: [ Contact ], viewController: ContactsViewController) {

        var cells = [ CellDataProtocol ]()
        for contact in contactList {
            let tableView = viewController.tableView!
            let contactCell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
            if let nickname = contact.nickname {
                contactCell.identLabel.text = nickname
            }
            else {
                let fragment = contact.publicId.prefix(10)
                contactCell.identLabel.text = String(fragment) + " ..."
            }
            contactCell.statusImageView.image = UIImage(named: contact.status)
            let cellData = ContactCellData(contactCell: contactCell,
                                           contact: contact, viewController: viewController)
            cells.append(cellData)
        }
        if cells.count > 0 {
            insertCells(cells, section: 1, at: 0)
        }

    }

}
