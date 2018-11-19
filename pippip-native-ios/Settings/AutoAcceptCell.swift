//
//  AutoAcceptCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 11/18/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class AutoAcceptCellItem: MultiCellItemProtocol {
    
    var cellReuseId: String = "AutoAcceptCell"
    var cellHeight: CGFloat = 65.0
    var currentCell: PippipTableViewCell?
    
}

class AutoAcceptCell: PippipTableViewCell, MultiCellProtocol {

    static var cellItem: MultiCellItemProtocol = AutoAcceptCellItem()
    
    var viewController: UITableViewController?
    var config = Configurator()

    @IBOutlet weak var autoAcceptSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func configure() {
        
        autoAcceptSwitch.isOn = config.autoAccept
        autoAcceptSwitch.onTintColor = PippipTheme.buttonColor

    }
    
    @IBAction func autoAcceptSwitched(_ sender: Any) {
        
        config.autoAccept = autoAcceptSwitch.isOn

    }

}
