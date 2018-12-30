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
    var currentCell: PippipTableViewCell?

}

class ContactPolicyCell: PippipTableViewCell, MultiCellProtocol {

    @IBOutlet weak var contactPolicySwitch: UISwitch!

    static var cellItem: MultiCellItemProtocol = ContactPolicyCellItem()
    var viewController: UITableViewController?
    var contactManager = ContactManager()
    var config = Configurator()
    var currentPolicy = "whitelist"
    var alertPresenter = AlertPresenter()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func configure() {
        
        currentPolicy = config.contactPolicy
        if (currentPolicy == "public") {
            contactPolicySwitch.setOn(true, animated: true)
        }
        else {
            contactPolicySwitch.setOn(false, animated: true)
        }
        contactPolicySwitch.onTintColor = PippipTheme.buttonColor

    }
    
    // Reset to new account default
    override func reset() {
        
        contactPolicySwitch.isOn = false
        
    }
    
    @objc func policyUpdated(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.PolicyUpdated, object: nil)
        guard let response = notification.object as? SetContactPolicyResponse else { return }
        if (response.result == "policySet") {
            currentPolicy = response.policy!
            config.contactPolicy = currentPolicy
            NotificationCenter.default.post(name: Notifications.PolicyChanged, object: response.policy)
            DispatchQueue.main.async {
                self.resetSwitch()
            }
        }
        else {
            alertPresenter.errorAlert(title: "PolicyError", message: "Invalid Server Response")
            DispatchQueue.main.async {
                self.resetSwitch()
            }
        }

    }

    func resetSwitch() {

        contactPolicySwitch.isEnabled = true
        if (currentPolicy == "public") {
            contactPolicySwitch.setOn(true, animated: true)
        }
        else {
            contactPolicySwitch.setOn(false, animated: true)
        }

    }

    @IBAction func policyChanged(_ sender: UISwitch) {

        var selectedPolicy = "whitelist"
        if (sender.isOn) {
            selectedPolicy = "public"
        }
        sender.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(policyUpdated(_:)),
                                               name: Notifications.PolicyUpdated, object: nil)
        contactManager.setContactPolicy(selectedPolicy)

    }

}
