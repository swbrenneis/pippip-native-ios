//
//  WhitelistTableModel.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/30/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class WhitelistHeaderView: ViewDataProtocol {
    
    var view: UIView
    var height: CGFloat
    
    init(_ frame: CGRect) {
        view = UIView(frame: frame)
        view.backgroundColor = UIColor(named: "Pale Gray")
        height = 40.0
    }
    
}

class WhitelistTableModel: BaseExpandingTableModel {

    weak var viewController: WhitelistViewController?

    init(_ viewController: WhitelistViewController) {

        super.init()
        self.viewController = viewController

    }

    func setFriends(whitelist: [Entity], tableView: ExpandingTableView) {

        tableModel[0]?.removeAll()
        var cells = [FriendCellData]()
        for entity in whitelist {
            let friendCell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") as! FriendCell
            if let nickname = entity.nickname {
                friendCell.cellView?.nicknameLabel.text = nickname
            }
            else {
                friendCell.cellView?.nicknameLabel.text = ""
            }
            friendCell.cellView?.publicIdLabel.text = entity.publicId
            let cellData = FriendCellData(friendCell: friendCell, tableView: tableView)
            cells.append(cellData)
        }
        insertCells(cells, section: 0, at: 0)

    }


}
