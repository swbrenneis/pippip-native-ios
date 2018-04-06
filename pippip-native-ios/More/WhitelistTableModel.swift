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

    func setFriends(whitelist: [[ AnyHashable: Any]], tableView: ExpandingTableView) {

        tableModel[0]?.removeAll()
        var cells = [FriendCellData]()
        for contact in whitelist {
            let friendCell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") as! FriendCell
            if let nickname = contact[AnyHashable("nickname")] as? String {
                friendCell.cellView?.nicknameLabel.text = nickname
            }
            else {
                friendCell.cellView?.nicknameLabel.text = ""
            }
            if let publicId = contact[AnyHashable("publicId")] as? String {
                friendCell.cellView?.publicIdLabel.text = publicId
            }
            else {
                friendCell.cellView?.publicIdLabel.text = ""
            }
            let cellData = FriendCellData(friendCell: friendCell, tableView: tableView)
            cells.append(cellData)
        }
        insertCells(cells, section: 0, at: 0)

    }


}
