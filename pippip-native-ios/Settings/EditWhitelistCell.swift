//
//  EditWhitelistCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/22/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class EditWhitelistCellItem: MultiCellItemProtocol {

    var cellReuseId: String = "EditWhitelistCell"
    var cellHeight: CGFloat = 50.0
    var currentCell: UITableViewCell?

}

class EditWhitelistCell: PippipTableViewCell, MultiCellProtocol {

    static var cellItem: MultiCellItemProtocol = EditWhitelistCellItem()
    var viewController: UITableViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func setDarkTheme() {
        
        self.textLabel?.textColor = PippipTheme.darkTextColor
        super.setDarkTheme()
        
    }
    
    override func setMediumTheme() {
        
        self.textLabel?.textColor = PippipTheme.mediumTextColor
        super.setMediumTheme()
        
    }
    
    override func setLightTheme() {
        
        self.textLabel?.textColor = PippipTheme.lightTextColor
        super.setLightTheme()
        
    }
    
}