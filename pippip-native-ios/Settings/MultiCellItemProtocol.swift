//
//  MultiCellItemProtocol.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/19/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

protocol MultiCellItemProtocol {

    var cellReuseId: String { get }
    var cellHeight: CGFloat { get }
    var currentCell: UITableViewCell? { set get }

}
