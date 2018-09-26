//
//  LocalAuthCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import LocalAuthentication

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

        let laContext = LAContext()
        var authError: NSError? = nil
        if (laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError)) {
            var laType = ""
            switch laContext.biometryType {
            case .none:
                laType = "Biometry not supported"
                localAuthSwitch.isEnabled = false
                localAuthSwitch.setOn(false, animated: true)
                config.useLocalAuth = false
                break
            case .touchID:
                laType = "Enable touch ID"
                localAuthSwitch.setOn(config.useLocalAuth, animated: true)
                break
            case .faceID:
                laType = "Enable face ID"
                localAuthSwitch.setOn(config.useLocalAuth, animated: true)
                break
            }
            localAuthLabel.text = laType
        }
        
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
