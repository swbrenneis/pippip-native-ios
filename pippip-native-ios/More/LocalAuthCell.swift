//
//  LocalAuthCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class LocalAuthCell: UITableViewCell {

    @IBOutlet weak var localAuthSwitch: UISwitch!

    var config = Configurator()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        localAuthSwitch.setOn(config.useLocalAuth, animated: true)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @objc class func cellItem() -> MoreCellItem {
        
        let item = MoreCellItem()
        item.cellHeight = 65.0
        item.cellReuseId = "LocalAuthCell"
        return item
        
    }
    
    @IBAction func localAuthChanged(_ sender: UISwitch) {

        config.useLocalAuth = sender.isOn

    }
}
