//
//  FriendCellData.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/30/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class FriendCellData: CellDataProtocol {

    var cellHeight: CGFloat = 70.0
    var cellId: String = "FriendCell"
    var selector: ExpandingTableSelectorProtocol?
    var userData: [String : Any]?
    var entity: [AnyHashable: Any]
    
    init(entity: [AnyHashable: Any]) {

        self.entity = entity

    }

    func configureCell(_ cell: UITableViewCell) {

        guard let friendCell = cell as? FriendCell else { return }
        let friendSelector = selector as! FriendCellSelector
        friendSelector.friendCell = friendCell
        if let nickname = entity["nickname"] as? String {
            friendCell.cellView?.nicknameLabel.text = nickname
        }
        else {
            friendCell.cellView?.nicknameLabel.text = ""
        }
        if let publicId = entity["publicId"] as? String {
            friendCell.cellView?.publicIdLabel.text = publicId
        }
        else {
            friendCell.cellView?.publicIdLabel.text = ""
        }

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

    var viewController: UIViewController?
    var tableView: ExpandingTableView?
    var friendCell: FriendCell?

    func didSelect(_ indexPath: IndexPath) {
        
        if friendCell!.isExpanded() {
            friendCell!.close()
            tableView?.collapseRow(at: indexPath)
        }
        else {
            friendCell!.open()
            let publicId = friendCell?.cellView?.publicIdLabel.text
            let deleteData = DeleteFriendCellData()
            let deleteSelector = DeleteFriendSelector(publicId: publicId!)
            deleteSelector.tableView = tableView
            deleteData.selector = deleteSelector
            tableView?.expandRow(at: indexPath, cells: [ deleteData ])
        }
    }
    
}

