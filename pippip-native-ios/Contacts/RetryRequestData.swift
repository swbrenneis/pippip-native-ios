//
//  RetryRequestData.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/18/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import RKDropdownAlert
import ChameleonFramework

class RetryRequestData: NSObject, CellDataProtocol {

    var cellHeight: CGFloat = 50.0
    var cellId: String = "RetryRequestCell"
    var selector: ExpandingTableSelectorProtocol?
    var userData: [String : Any]?
    
    func configureCell(_ cell: UITableViewCell) {
        // Nothing to do
    }
    

}

class RetryRequestSelector: NSObject, ExpandingTableSelectorProtocol {
    var viewController: UIViewController?
    
    var tableView: ExpandingTableView?
    var contact: Contact!
    var contactManager = ContactManager()
    var publicId: String

    init(publicId: String) {

        self.publicId = publicId

    }

    func didSelect(_ indexPath: IndexPath) {

        contactManager.requestContact(publicId: publicId, nickname: nil, retry: true)
        tableView?.collapseRow(at: IndexPath(row: indexPath.row - 3, section: indexPath.section))
        let alertColor = UIColor.flatLime
        RKDropdownAlert.title("Request Sent", message: "Your contact request has been sent",
                              backgroundColor: alertColor,
                              textColor: ContrastColorOf(alertColor, returnFlat: true),
                              time: 2, delegate: nil)

    }

}
