//
//  LastSeenCellData.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/31/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class LastSeenCellData: CellDataProtocol {

    var cell: UITableViewCell
    var cellHeight: CGFloat
    var selector: ExpandingTableSelectorProtocol
    var userData: [String : Any]?
    
    init(contactCell: LastSeenCell, tableView: ExpandingTableView) {
        
        cell = contactCell
        cellHeight = LastSeenCell.cellHeight
        selector = NoopTableSelector()
        
    }
    

}
