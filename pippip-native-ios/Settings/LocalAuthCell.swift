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
    var initialState: Bool!

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

        initialState = config.useLocalAuth
        localAuthSwitch.onTintColor = PippipTheme.buttonColor
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func localAuthChanged(_ sender: UISwitch) {

        if sender.isOn {
            if let settingsViewController = viewController as? SettingsTableViewController {
                if config.uuid.count == 0 {
                    config.uuid = UUID().uuidString
                }
                settingsViewController.showStorePassphraseView(cell: self)
            }
        }
        else {
            let keychain = Keychain(service: Keychain.PIPPIP_TOKEN_SERVICE)
            do {
                try keychain.remove(key: config.uuid)
                config.useLocalAuth = false
                initialState = false
            }
            catch {
                print("Error deleting keychain passphrase: \(error.localizedDescription)")
                config.useLocalAuth = true
                initialState = true
                DispatchQueue.main.async {
                    self.localAuthSwitch.setOn(true, animated: true)
                }
            }
        }

    }

}
