//
//  ExpandingTableSelectorProtocol.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/30/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

protocol ExpandingTableSelectorProtocol {

    func didSelect(_ indexPath: IndexPath)

}

class NoopTableSelector: ExpandingTableSelectorProtocol {
    func didSelect(_ indexPath: IndexPath) { }
}

