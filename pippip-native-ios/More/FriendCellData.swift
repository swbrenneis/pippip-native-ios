//
//  FriendCellData.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/30/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class FriendCellData: CellDataProtocol {

    var cell: UITableViewCell
    var cellHeight: CGFloat
    var selector: ExpandingTableSelectorProtocol
    var userData: [String : Any]?
    
    init(friendCell: FriendCell, tableView: ExpandingTableView) {
        
        cell = friendCell
        cellHeight = 70.0
        let friendSelector = FriendCellSelector()
        friendSelector.friendCell = friendCell
        friendSelector.tableView = tableView
        selector = friendSelector
        
    }
    
}

class FriendCell : ExpandingTableViewCell {

    var cellView: ContactCellView?
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
        cellView = ContactCellView(frame: self.bounds)
        self.addSubview(cellView!)
        
    }
    
}

class FriendCellSelector: ExpandingTableSelectorProtocol {
    
    weak var tableView: ExpandingTableView?
    weak var friendCell: FriendCell?

    func didSelect(_ indexPath: IndexPath) {
        
        if friendCell!.isExpanded() {
            friendCell!.close()
            tableView?.collapseRow(at: indexPath, count: 1)
        }
        else {
            friendCell!.open()
            let publicId = friendCell?.cellView?.publicIdLabel.text
            let deleteData = DeleteFriendCellData(publicId: publicId!, tableView: tableView!)
            tableView?.expandRow(at: indexPath, cells: [ deleteData ])
        }
    }
    
}

