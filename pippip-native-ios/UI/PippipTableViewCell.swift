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

    func setDarkTheme() {
        
        self.backgroundColor = .clear
        contentView.backgroundColor = PippipTheme.darkCellColor
        contentView.layer.cornerRadius = PippipTheme.cellCorners
        contentView.layer.masksToBounds = true

    }
    
    func setMediumTheme() {
        
        self.backgroundColor = .clear
        contentView.backgroundColor = PippipTheme.mediumCellColor
        contentView.layer.cornerRadius = PippipTheme.cellCorners
        contentView.layer.masksToBounds = true

    }
    
    func setLightTheme() {
        
        self.backgroundColor = .clear
        contentView.backgroundColor = PippipTheme.lightCellColor
        contentView.layer.cornerRadius = PippipTheme.cellCorners
        contentView.layer.masksToBounds = true
        
    }
    
}
