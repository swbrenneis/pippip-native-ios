//
//  ContactPublicIdData.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/31/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ContactPublicIdData: CellDataProtocol {

    var cell: UITableViewCell
    var cellHeight: CGFloat
    var selector: ExpandingTableSelectorProtocol
    var userData: [String : Any]?
    
    init(contactPublicIdCell: ContactPublicIdCell, tableView: ExpandingTableView) {
        
        cell = contactPublicIdCell
        cellHeight = 70.0
        selector = NoopTableSelector()
        
    }
    
}
