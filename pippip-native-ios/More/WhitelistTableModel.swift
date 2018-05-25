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

    override init() {

        super.init()

        expandingCells[0] = [ExpandingTableViewCell]()

    }

    func setFriends(whitelist: [Entity], tableView: ExpandingTableView) {

        clear(section: 0)
        guard let cells = createCells(cellId: "FriendCell", count: whitelist.count) as? [ExpandingTableViewCell]
            else { return }
        for index in 0..<cells.count {
            let cell = cells[index]
            let entity = whitelist[index]
            cell.setMediumTheme()
            cell.textLabel?.text = entity.nickname
            cell.detailTextLabel?.text = entity.publicId
            let friendSelector = FriendCellSelector()
            friendSelector.tableView = tableView
            cell.selector = friendSelector
            // Add child and selector
            let deleteCells = createCells(cellId: "DeleteFriendCell", count: 1)
            deleteCells[0].setLightTheme()
            let deleteFriendSelector = DeleteFriendSelector(publicId: entity.publicId)
            deleteFriendSelector.tableView = tableView
            deleteCells[0].selector = deleteFriendSelector
            cell.children = deleteCells
        }
        appendExpandingCells(cells: cells, section: 0, animation: .bottom)

    }

    func getFriendCell(entity: Entity) -> ExpandingTableCell {
        
        guard let cells = createCells(cellId: "FriendCell", count: 1) as? [ExpandingTableViewCell]
            else { return ExpandingTableCell() }
        let cell = cells[0]
        cell.setMediumTheme()
        cell.textLabel?.text = entity.nickname
        cell.detailTextLabel?.text = entity.publicId
        let friendSelector = FriendCellSelector()
        friendSelector.tableView = tableView
        cell.selector = friendSelector
        // Add child and selector
        let deleteCells = createCells(cellId: "DeleteFriendCell", count: 1)
        deleteCells[0].setLightTheme()
        let deleteFriendSelector = DeleteFriendSelector(publicId: entity.publicId)
        deleteFriendSelector.tableView = tableView
        deleteCells[0].selector = deleteFriendSelector
        cell.children = deleteCells
        return cell

    }

}
