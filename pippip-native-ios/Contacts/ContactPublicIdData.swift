//
//  ContactPublicIdData.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/31/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ContactPublicIdData: NSObject, CellDataProtocol {

    var cellId: String = "ContactPublicIdCell"
    var cellHeight: CGFloat = 70.0
    var selector: ExpandingTableSelectorProtocol?
    var userData: [String : Any]?
    var publicId: String

    init(publicId: String) {

        self.publicId = publicId

        super.init()

    }

    func configureCell(_ cell: UITableViewCell) {

        let publicIdCell = cell as? ContactPublicIdCell
        publicIdCell?.publicIdLabel.text = publicId

    }

}
