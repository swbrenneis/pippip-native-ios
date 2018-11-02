//
//  PippipTableViewCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/19/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class PippipTableViewCell: UITableViewCell {

    static var nextCell: Int = 0
    var cellHeight: CGFloat = 55.0
    var cellId: Int = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        PippipTableViewCell.nextCell += 1
        cellId = PippipTableViewCell.nextCell
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure() {
        // Does nothing
    }

    func reset() {
        // Does nothing.
    }
    
    func setTheme() {
        
        self.backgroundColor = UIColor.flatWhite
        contentView.backgroundColor = UIColor.flatWhite

    }
    
}
