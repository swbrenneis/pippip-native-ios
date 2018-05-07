//
//  ContactPolicyCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/10/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ContactPolicyCell: UITableViewCell {

    @IBOutlet weak var contactPolicySwitch: UISwitch!

    var contactManager = ContactManager()
    var config = Configurator()
    var currentPolicy = "whitelist"
    var selectedPolicy = "whitelist"

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

        NotificationCenter.default.addObserver(self, selector: #selector(policyUpdated(_:)),
                                               name: Notifications.PolicyUpdated, object: nil)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @objc class func cellItem() -> MoreCellItem {
        
        let item = MoreCellItem()
        item.cellHeight = 65.0
        item.cellReuseId = "ContactPolicyCell"
        return item
        
    }

    @objc func policyUpdated(_ notification: Notification) {

        guard let info = notification.userInfo else { return }
        if let result = info["result"] as? String {
            DispatchQueue.main.async {
                if (result == "policySet") {
                    self.currentPolicy = self.selectedPolicy
                    self.config.contactPolicy = self.currentPolicy
                    var info = [AnyHashable: Any]()
                    info["policy"] = self.currentPolicy
                    NotificationCenter.default.post(name: Notifications.PolicyChanged, object: nil,
                                                    userInfo: info)
                }
                self.resetCell()
            }
        }
        else {
            var info = [AnyHashable: Any]()
            info["title"] = "Policy Error"
            info["message"] = "Invalid server response"
            NotificationCenter.default.post(name: Notifications.PresentAlert, object: nil, userInfo: info)
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
