//
//  ShowIgnoredCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ShowIgnoredCellItem: MultiCellItemProtocol {
    
    var cellReuseId: String = "ShowIgnoredCell"
    var cellHeight: CGFloat = 65.0
    var currentCell: UITableViewCell?
    
}

class ShowIgnoredCell: PippipTableViewCell, MultiCellProtocol {

    @IBOutlet weak var ignoredSwitch: UISwitch!
 
    static var cellItem: MultiCellItemProtocol = ShowIgnoredCellItem()
    var viewController: UITableViewController?
    var config = Configurator()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        ignoredSwitch.isOn = config.showIgnoredContacts
        ignoredSwitch.onTintColor = PippipTheme.buttonColor

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func showIgnoredTapped(_ sender: UISwitch) {

        config.showIgnoredContacts = sender.isOn
        
    }
}
