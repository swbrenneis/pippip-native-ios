//
//  LocalAuthCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class LocalAuthCellItem: MultiCellItemProtocol {

    var cellReuseId: String = "LocalAuthCell"
    var cellHeight: CGFloat = 65.0
    var currentCell: UITableViewCell?

}

class LocalAuthCell: PippipTableViewCell, MultiCellProtocol {
    @IBOutlet weak var localAuthSwitch: UISwitch!

    static var cellItem: MultiCellItemProtocol = LocalAuthCellItem()
    var viewController: UITableViewController?
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

    @IBAction func localAuthChanged(_ sender: UISwitch) {

        config.useLocalAuth = sender.isOn

    }
}
