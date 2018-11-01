//
//  LocalPasswordCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/9/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework

class LocalPasswordCellItem: MultiCellItemProtocol {

    var cellReuseId: String = "LocalPasswordCell"
    var cellHeight: CGFloat = 65.0
    var currentCell: UITableViewCell?

}

class LocalPassphraseCell: PippipTableViewCell, MultiCellProtocol {

    @IBOutlet weak var changePassphraseLabel: UILabel!
    
    static var cellItem: MultiCellItemProtocol = LocalPasswordCellItem()
    let obscured = "***********"
    var viewController: UITableViewController?
    var sessionState = SessionState()
    var alertPresenter = AlertPresenter()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        changePassphraseLabel.backgroundColor = PippipTheme.lightBarColor
        changePassphraseLabel.textColor = UIColor.flatTealDark
        changePassphraseLabel.layer.cornerRadius = 7.0
        changePassphraseLabel.layer.masksToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            if let settingsViewController = viewController as? SettingsTableViewController {
                settingsViewController.showChangePassphraseView()
            }
        }

    }
/*
    func doChangePassphrase(oldPassphrase: String, newPassphrase: String) {

        let vault = UserVault()
        do {
            try vault.changePassphrase(oldPassphrase: oldPassphrase, newPassphrase: newPassphrase)
            alertPresenter.successAlert(title: "Passphrase Changed", message: "Your local passphrase has been changed")
            resetCell()
        }
        catch {
            alertPresenter.errorAlert(title: "Change Passphrase Error",
                                      message: "An error has occurred, please try again")
        }
    }

    func emptyPassphrase (oldPassphrase: String, newPassphrase: String) {

        DispatchQueue.main.async {
            let alert = PMAlertController(title: "Change Passphrase",
                                          description: "Empty passphrases are not recommended\nProceed?",
                                          image: nil,
                                          style: .alert)
            alert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
                self.doChangePassphrase(oldPassphrase: oldPassphrase, newPassphrase: newPassphrase)
            }))
            alert.addAction(PMAlertAction(title: "No", style: .cancel, action: { () in
                self.resetCell()
            }))
            self.viewController?.present(alert, animated: true, completion: nil)
        }

    }

    func newPassphrase(_ oldPassphrase: String) {

        let passphrase = passphraseText.text!
        if passphrase.utf8.count == 0 {
            self.emptyPassphrase(oldPassphrase: oldPassphrase, newPassphrase: passphrase)
        }
        else {
            self.doChangePassphrase(oldPassphrase: oldPassphrase, newPassphrase: passphrase)
        }
    
    }
*/
}