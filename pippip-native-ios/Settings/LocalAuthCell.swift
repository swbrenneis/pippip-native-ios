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
    var currentCell: PippipTableViewCell?

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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func configure() {

        let laContext = LAContext()
        var authError: NSError? = nil
        if (laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError)) {
            switch laContext.biometryType {
            case .none:
                localAuthLabel.text = "\(PippipTheme.leadingLAType!) not available"
                localAuthSwitch.isEnabled = false
                localAuthSwitch.setOn(false, animated: true)
                config.useLocalAuth = false
                break
            case .touchID, .faceID:
                localAuthLabel.text = "Enable \(PippipTheme.localAuthType!)"
                localAuthSwitch.setOn(config.useLocalAuth, animated: true)
                break
            }
        }
        else {
            localAuthLabel.text = "\(PippipTheme.leadingLAType!) not available"
            localAuthSwitch.isEnabled = false
            localAuthSwitch.setOn(false, animated: true)
            config.useLocalAuth = false
        }
        
        initialState = config.useLocalAuth
        localAuthSwitch.onTintColor = PippipTheme.buttonColor
        
    }
    
    // Reset to configuration default
    override func reset() {
    
        localAuthSwitch.isOn = true
    
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
