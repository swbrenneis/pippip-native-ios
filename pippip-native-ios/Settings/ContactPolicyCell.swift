//
//  ContactPolicyCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/10/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ContactPolicyCellItem: MultiCellItemProtocol {

    var cellReuseId: String = "ContactPolicyCell"
    var cellHeight: CGFloat = 65.0
    var currentCell: UITableViewCell?

}

class ContactPolicyCell: PippipTableViewCell, MultiCellProtocol {

    @IBOutlet weak var contactPolicySwitch: UISwitch!

    static var cellItem: MultiCellItemProtocol = ContactPolicyCellItem()
    var viewController: UITableViewController?
    var contactManager = ContactManager()
    var config = Configurator()
    var currentPolicy = "whitelist"
    var selectedPolicy = "whitelist"
    var alertPresenter = AlertPresenter()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        currentPolicy = config.contactPolicy
        if (currentPolicy == "public") {
            contactPolicySwitch.setOn(true, animated: true)
        }
        else {
            contactPolicySwitch.setOn(false, animated: true)
        }
        contactPolicySwitch.onTintColor = PippipTheme.buttonColor

        NotificationCenter.default.addObserver(self, selector: #selector(policyUpdated(_:)),
                                               name: Notifications.PolicyUpdated, object: nil)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @objc func policyUpdated(_ notification: Notification) {

        guard let response = notification.object as? SetContactPolicyResponse else { return }
        if (response.result == "policySet") {
            self.currentPolicy = self.selectedPolicy
            self.config.contactPolicy = self.currentPolicy
            var info = [AnyHashable: Any]()
            info["policy"] = self.currentPolicy
            NotificationCenter.default.post(name: Notifications.PolicyChanged, object: response.policy)
            DispatchQueue.main.async {
                self.resetCell()
            }
        }
        else {
            alertPresenter.errorAlert(title: "PolicyError", message: "Invlaid Server Response")
            DispatchQueue.main.async {
                self.resetCell()
            }
        }

    }

    func resetCell() {

        if (currentPolicy == "public") {
            contactPolicySwitch.setOn(true, animated: true)
        }
        else {
            contactPolicySwitch.setOn(false, animated: true)
        }

    }

    @IBAction func policyChanged(_ sender: UISwitch) {

        if (sender.isOn) {
            selectedPolicy = "public"
        }
        else {
            selectedPolicy = "whitelist"
        }
        contactManager.setContactPolicy(selectedPolicy)

    }

}
