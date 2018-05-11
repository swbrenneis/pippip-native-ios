//
//  LastSeenCellData.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/31/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class LastSeenCellData: CellDataProtocol {

    var cellId: String = "LastSeenCell"
    var cellHeight: CGFloat
    var selector: ExpandingTableSelectorProtocol?
    var userData: [String : Any]?
    var contact: Contact
    var lastSeenFormatter: DateFormatter

    init(contact: Contact) {

        self.contact = contact
        cellHeight = LastSeenCell.cellHeight
        lastSeenFormatter = DateFormatter()
        lastSeenFormatter.dateFormat = "MMM dd YYYY hh:mm"

    }

    func configureCell(_ cell: UITableViewCell) {

        guard let lastSeenCell = cell as? LastSeenCell else { return }
        if (contact.timestamp == 0) {
            lastSeenCell.lastSeenLabel.text = "Never"
        }
        else {
            let tsDate = Date.init(timeIntervalSince1970: TimeInterval(contact.timestamp))
            lastSeenCell.lastSeenLabel.text = lastSeenFormatter.string(from: tsDate)
        }

    }

}
