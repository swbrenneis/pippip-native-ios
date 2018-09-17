//
//  LocalAuthCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import DeviceKit

class LocalAuthCellItem: MultiCellItemProtocol {

    var cellReuseId: String = "LocalAuthCell"
    var cellHeight: CGFloat = 65.0
    var currentCell: UITableViewCell?

}

class LocalAuthCell: PippipTableViewCell, MultiCellProtocol {
    
    @IBOutlet weak var localAuthSwitch: UISwitch!
    @IBOutlet weak var localAuthLabel: UILabel!
    
    static var cellItem: MultiCellItemProtocol = LocalAuthCellItem()
    var viewController: UITableViewController?
    var config = Configurator()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let device = Device()
        var laType = "Enable thumbprint"
        if device == .iPhoneX {
            laType = "Enable facial recognition"
        }
        localAuthLabel.text = laType
        
        localAuthSwitch.setOn(config.useLocalAuth, animated: true)
        localAuthSwitch.onTintColor = PippipTheme.buttonColor
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func localAuthChanged(_ sender: UISwitch) {

        config.useLocalAuth = sender.isOn

    }

}
