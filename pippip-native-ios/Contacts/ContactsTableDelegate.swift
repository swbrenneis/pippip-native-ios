//
//  ContactsTableDelegate.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import PMAlertController

class ContactsTableDelegate {

    weak var viewController: ContactsViewController!
    var contactList = [ [ AnyHashable: Any ] ]()
    var pendingRequests = [ [ AnyHashable: Any ] ]()
    var selectedContact = [ AnyHashable: Any ]()
    var contactManager = ContactManager()
    var debugging = false

    func expandingTableView(_ expandingTableView: ExpandingTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let cell = expandingTableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as? ContactCell
            let contact = contactList[indexPath.item]
            if let status = contact[AnyHashable("status")] as? String {
                cell?.statusImageView.image  = UIImage(named: status)
            }
            if let nickname = contact[AnyHashable("nickname")] as? String {
                cell?.identLabel.text = nickname
            }
            else if let publicId = contact[AnyHashable("publicId")] as? String {
                cell?.identLabel.text = publicId.prefix(10) + "..."
            }
            return cell!
        }
        else {
            if debugging && indexPath.item == 2 {
                let cell = expandingTableView.dequeueReusableCell(withIdentifier: "SyncContactsCell", for: indexPath)
                return cell
            }
            else if indexPath.item == 0 {
                let cell = expandingTableView.dequeueReusableCell(withIdentifier: "NewContactCell", for: indexPath)
                return cell
            }
            else  {
                let cell = expandingTableView.dequeueReusableCell(withIdentifier: "PendingContactsCell", for: indexPath)
                return cell
            }
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func expandingTableView(_ expandingTableView: ExpandingTableView, numberOfExpandingCellsForRowAt indexPath: IndexPath) -> Int {

        if indexPath.section == 0 {
            return 3
        }
        else {
            return 0
        }

    }
    
    func expandingTableView(_ expandingTableView: ExpandingTableView,
                            expansionCellForRowAt parent: IndexPath, index: Int) -> UITableViewCell {

        if parent.section == 0 {
            let contact = contactList[parent.item]
            switch index {
            case 0:
                // Last seen cell
                let timestamp = contact[AnyHashable("timestamp")] as? NSNumber
                let tsDate = Date.init(timeIntervalSince1970: (timestamp?.doubleValue)!)
                let dayTimePeriodFormatter = DateFormatter()
                dayTimePeriodFormatter.dateFormat = "MMM dd YYYY hh:mm"
                let lastSeenCell =
                    expandingTableView.dequeueReusableCell(withIdentifier: "LastSeenCell") as? LastSeenCell
                lastSeenCell?.lastSeenLabel.text = dayTimePeriodFormatter.string(from: tsDate)
                return lastSeenCell!
            case 1:
                // Public ID cell
                let publicIdCell =
                    expandingTableView.dequeueReusableCell(withIdentifier: "ContactPublicIdCell") as? ContactPublicIdCell
                let publicId = contact[AnyHashable("publicId")] as? String
                publicIdCell?.publicIdLabel.text = publicId
                return publicIdCell!
            case 2:
                // Delete contact cell
                let deleteContactCell = expandingTableView.dequeueReusableCell(withIdentifier: "DeleteContactCell")
                return deleteContactCell!
            default:
                return UITableViewCell()
            }
        }
        else {
            return UITableViewCell()
        }

    }
    
    func canExpandCell(at IndexPath: IndexPath) -> Bool {
        return false
    }
    
    func expandingTableView(_ expandingTableView: ExpandingTableView, didSelectExpansionRowAt parent: IndexPath, index: Int) {
        
    }
    
    func expandingTableView(_ expandingTableView: ExpandingTableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 1 {
            let alert = PMAlertController(title: "Add A New Contact",
                                          description: "Enter a nickname or public ID",
                                          image: nil,
                                          style: PMAlertControllerStyle.alert)
            alert.addTextField({ (textField) in
                textField?.placeholder = "Nickname"
            })
            alert.addTextField({ (textField) in
                textField?.placeholder = "Public ID"
            })
            alert.addAction(PMAlertAction(title: "Request Contact",
                                          style: .default, action: { () in
                                            let nickname = alert.textFields[0].text ?? ""
                                            let publicId = alert.textFields[1].text ?? ""
                                            if nickname.utf8.count > 0 {
                                                self.contactManager.matchNickname(nickname, withPublicId: nil)
                                            }
                                            else if publicId.utf8.count > 0 {
                                                self.contactManager.requestContact(publicId, withNickname: nickname)
                                            }
            }))
            alert.addAction(PMAlertAction(title: "Cancel", style: .cancel))
            self.viewController.present(alert, animated: true, completion: nil)
        }

    }
    

    func expandingTableView(_ expandingTableView: ExpandingTableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            return contactList.count
        }
        else {
            var count = 1
            if debugging {
                count += 1
            }
            if (pendingRequests.count > 0) {
                count += 1
            }
            return count
        }
        
    }

    func expandingTableView(_ expandableTableView: ExpandingTableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        if (indexPath.section == 0) {
            return 75.0
        }
        else {
            return 50.0
        }
    
    }
    
    func expandingTableView(_ expandingTableView: ExpandingTableView,
                            heightForExpandedRowAt parent: IndexPath, index: Int) -> CGFloat {

        if parent.section == 0 {
            switch index {
            case 0:
                return 45.0
            case 1:
                return 63.0
            case 2:
                return 50.0
            default:
                return 0.0
            }
        }
        else {
            return 0.0
        }
        
    }
    
    
}
