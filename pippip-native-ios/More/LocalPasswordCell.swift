//
//  LocalPasswordCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/9/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import PMAlertController
import RKDropdownAlert
import ChameleonFramework

class LocalPasswordCell: TableViewCellWithController {

    @IBOutlet weak var passphraseText: UITextField!
    @IBOutlet weak var changePassphraseButton: UIButton!

    var sessionState = SessionState()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        changePassphraseButton.isEnabled = false
        changePassphraseButton.alpha = 0.0
        
    }
    @objc class func cellItem() -> MoreCellItem {
        
        let item = MoreCellItem()
        item.cellHeight = 65.0
        item.cellReuseId = "LocalPasswordCell"
        return item
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func doChangePassphrase(oldPassphrase: String, newPassphrase: String) {

        let vault = UserVault()
        do {
            try vault.changePassphrase(oldPassphrase: oldPassphrase, newPassphrase: newPassphrase)
            let alertColor = UIColor.flatLime
            RKDropdownAlert.title("Passphrase Changed", message: "Your local passphrase has been changed",
                                  backgroundColor: alertColor,
                                  textColor: ContrastColorOf(alertColor, returnFlat: true),
                                  time: 2, delegate: nil)
            resetCell()
        }
        catch {
            var info = [AnyHashable: Any]()
            info["title"] = "Change Passphrase Exception"
            info["message"] = "An error has occurred, please try again"
            NotificationCenter.default.post(name: Notifications.PresentAlert, object: nil, userInfo: info)
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

    func resetCell() {

        passphraseText.text = "***********"
        changePassphraseButton.alpha = 0.0
        changePassphraseButton.isEnabled = false

    }
    
    @IBAction func changePassphrase(_ sender: Any) {

        let alert = PMAlertController(title: "Change Passphrase",
                                      description: "Enter your current passphrase",
                                      image: nil,
                                      style: .alert)
        alert.addTextField({ (textField) in
            textField?.placeholder = "Passphrase"
            textField?.autocorrectionType = .no
            textField?.spellCheckingType = .no
            textField?.autocapitalizationType = .none
            textField?.becomeFirstResponder()
        })
        alert.addAction(PMAlertAction(title: "Verify Passphrase", style: .default, action: { () in
            let passphrase = alert.textFields[0].text ?? ""
            do {
                if try UserVault.validatePassphrase(passphrase) {
                    self.newPassphrase(passphrase)
                }
                else {
                    var info = [AnyHashable: Any]()
                    info["title"] = "Verify Passphrase"
                    info["message"] = "Invalid passphrase"
                    NotificationCenter.default.post(name: Notifications.PresentAlert, object: nil, userInfo: info)
                    self.resetCell()
                }
            }
            catch {
                var info = [AnyHashable: Any]()
                info["title"] = "Verify Passphrase Exception"
                info["message"] = "An error has occurred, please try again"
                NotificationCenter.default.post(name: Notifications.PresentAlert, object: nil, userInfo: info)
            }
        }))
        alert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
            self.resetCell()
        }))
        viewController?.present(alert, animated: true, completion: nil)

    }

    @IBAction func passphraseChanged(_ sender: Any) {

        changePassphraseButton.alpha = 1.0
        changePassphraseButton.isEnabled = true

    }

}
