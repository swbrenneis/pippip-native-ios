//
//  EditWhitelistCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/22/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class EditWhitelistCell: UITableViewCell {

    @objc class func cellItem() -> MoreCellItem {
        
        let item: MoreCellItem = MoreCellItem()
        item.cellHeight = 50.0
        item.cellReuseId = "EditWhitelistCell"
        return item
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
