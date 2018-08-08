//
//  DeleteAccountCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import PMAlertController
import ChameleonFramework

class DeleteAccountCellItem: MultiCellItemProtocol {

    var cellReuseId: String = "DeleteAccountCell"
    var cellHeight: CGFloat = 45.0
    var currentCell: UITableViewCell?
    
}

class DeleteAccountCell: PippipTableViewCell, MultiCellProtocol {

    static var cellItem: MultiCellItemProtocol = DeleteAccountCellItem()
    var viewController: UITableViewController?
    var accountDeleter = AccountDeleter()
    var sessionState = SessionState()
    var alertPresenter = AlertPresenter()

    override func awakeFromNib() {
        super.awakeFromNib()

        //self.textLabel?.textColor = UIColor.flatRed

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            validateDelete()
        }

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

        let accountName = AccountSession.accountName
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
                                        do {
                                            if try UserVault.validatePassphrase(passphrase) {
                                                try self.accountDeleter.deleteAccount(accountName: accountName!)
                                                self.alertPresenter.successAlert(title: "Account Deleted",
                                                                                 message: "This account has been deleted and you will now be logged out")
                                                NotificationCenter.default.post(name: Notifications.AccountDeleted,
                                                                                object: nil)
                                            }
                                            else {
                                                self.alertPresenter.infoAlert(title: "Invalid Passphrase",
                                                                              message: "Invalid passphrase, account not deleted")
                                            }
                                        }
                                        catch {
                                            print("Error while deleting account: \(error)")
                                        }
        }))
        alert.addAction(PMAlertAction(title: "Cancel", style: .cancel))
        viewController?.present(alert, animated: true, completion: nil)
        
    }

}
