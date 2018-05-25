//
//  MultiCellProtocol.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/19/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

protocol MultiCellProtocol {

    static var cellItem: MultiCellItemProtocol { get }
    var viewController: UITableViewController? { get set }

}
