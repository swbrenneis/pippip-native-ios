//
//  ExpandingTableSelectorProtocol.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/30/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

protocol ExpandingTableSelectorProtocol {

    var viewController: UIViewController? { get set }
    var tableView: ExpandingTableView? { get set }

    func didSelect(_ indexPath: IndexPath)

}
