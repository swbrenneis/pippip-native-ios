//
//  DeleteAccountCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import PMAlertController
import RKDropdownAlert
import ChameleonFramework

class DeleteAccountCell: TableViewCellWithController, RKDropdownAlertDelegate {

    var accountDeleter = AccountDeleter()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            validateDelete()
        }

    }

    @objc class func cellItem() -> MoreCellItem {

        let item = MoreCellItem()
        item.cellHeight = 45.0
        item.cellReuseId = "DeleteAccountCell"
        return item

    }

    func validateDelete() {

        let alert = PMAlertController(title: "CAUTION!",
                                      description: "You are about to delete your account\n"
                                                    + "This action cannot be undone\n"
                                                    + "Proceed?",
                                      image: nil,
                                      style: PMAlertControllerStyle.alert)
        alert.addAction(PMAlertAction(title: "Yes",
                                      style: .cancel, action: { () in
                                        DispatchQueue.main.async {
                                            self.checkPassphrase()
                                        }
        }))
        alert.addAction(PMAlertAction(title: "No", style: .default))
        viewController?.present(alert, animated: true, completion: nil)

    }

    func checkPassphrase() {

        let accountName = ApplicationSingleton.instance().accountSession.sessionState.currentAccount!
        let alert = PMAlertController(title: "Delete Account",
                                      description: "Enter your passphrase",
                                      image: nil,
                                      style: PMAlertControllerStyle.alert)
        alert.addTextField({ (textField) in
            textField?.placeholder = "Passphrase"
            textField?.autocorrectionType = .no
            textField?.spellCheckingType = .no
            textField?.autocapitalizationType = .none
        })
        alert.addAction(PMAlertAction(title: "OK",
                                      style: .default, action: { () in
                                        let passphrase = alert.textFields[0].text ?? ""
                                        if self.accountDeleter.validatePassphrase(passphrase)
                                            && self.accountDeleter.deleteAccount(accountName) {
                                            var info = [AnyHashable: Any]()
                                            info["title"] = "Account Deleted"
                                            info["message"] = "This account has been deleted and will now be logged out"
                                            NotificationCenter.default.post(name: Notifications.PresentAlert,
                                                                            object: nil, userInfo: info)
                                            NotificationCenter.default.post(name: Notifications.AccountDeleted, object: nil)
                                        }
                                        else {
                                            var info = [AnyHashable: Any]()
                                            info["title"] = "Invalid Passphrase"
                                            info["message"] = "Invalid passphrase\nAccount not deleted"
                                            NotificationCenter.default.post(name: Notifications.PresentAlert,
                                                                            object: nil, userInfo: info)
                                        }
        }))
        alert.addAction(PMAlertAction(title: "Cancel", style: .cancel))
        viewController?.present(alert, animated: true, completion: nil)
        
    }

    func dropdownAlertWasTapped(_ alert: RKDropdownAlert!) -> Bool {
        return true
    }
    
    func dropdownAlertWasDismissed() -> Bool {
        return true
    }
    
}
