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
            let cellData = FriendCellData(entity: contact)
            let friendSelector = FriendCellSelector()
            friendSelector.tableView = tableView
            cellData.selector = friendSelector
            cells.append(cellData)
        }
        appendCells(cellData: cells, section: 0, with: .left)

    }


}
