//
//  AddContactCellData.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/31/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import PMAlertController
import RKDropdownAlert
import ChameleonFramework

class NewContactCellData: CellDataProtocol {

    var cell: UITableViewCell
    var cellHeight: CGFloat
    var selector: ExpandingTableSelectorProtocol
    var userData: [String : Any]?
    
    init(_ viewController: ContactsViewController) {
        
        cell = viewController.tableView.dequeueReusableCell(withIdentifier: "NewContactCell")!
        cellHeight = 50.0
        let contactSelector = NewContactSelector(viewController)
        contactSelector.cell = cell
        selector = contactSelector
        
    }
    
}

class NewContactSelector: ExpandingTableSelectorProtocol {
    
    weak var viewController: ContactsViewController?
    weak var cell: UITableViewCell?
    var contactManager: ContactManager
    var tableView: ExpandingTableView
    var nickname = ""
    var publicId = ""
    
    init(_ viewController: ContactsViewController) {
        
        self.viewController = viewController
        tableView = self.viewController!.tableView
        contactManager = ContactManager()

    }
    
    func didSelect(_ indexPath: IndexPath) {

        NotificationCenter.default.addObserver(self, selector: #selector(contactRequested(_:)),
                                               name: Notifications.ContactRequested, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(nicknameMatched(_:)),
                                               name: Notifications.NicknameMatched, object: nil)

        cell?.setSelected(false, animated: true)
        let alert = PMAlertController(title: "Add A New Contact",
                                      description: "Enter a nickname or public ID",
                                      image: nil,
                                      style: PMAlertControllerStyle.alert)
        alert.addTextField({ (textField) in
            textField?.placeholder = "Nickname"
            textField?.autocorrectionType = .no
            textField?.spellCheckingType = .no
        })
        alert.addTextField({ (textField) in
            textField?.placeholder = "Public ID"
            textField?.autocorrectionType = .no
            textField?.spellCheckingType = .no
        })
        alert.addAction(PMAlertAction(title: "Add Contact",
                                      style: .default, action: { () in
                                        self.nickname = alert.textFields[0].text ?? ""
                                        self.publicId = alert.textFields[1].text ?? ""
                                        if self.nickname.utf8.count > 0 {
                                            self.contactManager.matchNickname(self.nickname, withPublicId: nil)
                                        }
                                        else if self.publicId.utf8.count > 0 {
                                            self.contactManager.requestContact(self.publicId, withNickname: nil)
                                        }
        }))
        alert.addAction(PMAlertAction(title: "Cancel", style: .cancel))
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    @objc func contactRequested(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.NicknameMatched, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.ContactRequested, object: nil)
        DispatchQueue.main.async {
            let contact = notification.object as! Contact
            let contactCell = self.tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
            if let nickname = contact.nickname {
                contactCell.identLabel.text = nickname
            }
            else {
                let fragment = contact.publicId.prefix(10)
                contactCell.identLabel.text = String(fragment) + " ..."
            }
            contactCell.statusImageView.image = UIImage(named: contact.status)
            let cellData = ContactCellData(contactCell: contactCell,
                                           contact: contact, viewController: self.viewController!)
            if let model = self.tableView.expandingModel {
                model.appendCell(cellData, section: 0)
                let alertColor = UIColor.flatLime
                RKDropdownAlert.title("Contact Added", message: "This contact has been added to your contacts list",
                                      backgroundColor: alertColor,
                                      textColor: ContrastColorOf(alertColor, returnFlat: true),
                                      time: 2, delegate: nil)
                self.tableView.insertRows(at: model.insertPaths, with: .right)
            }
        }

    }

    @objc func nicknameMatched(_ notification: Notification) {
        
        let info = notification.userInfo!
        if let puid = info["publicId"] as? String {
            publicId = puid
            nickname = info["nickname"] as? String ?? ""
            contactManager.requestContact(publicId, withNickname: nickname)
        }
        else {
            DispatchQueue.main.async {
                let alertColor = UIColor.flatSand
                RKDropdownAlert.title("Add Contact Error", message: "That nickname doesn't exist",
                                      backgroundColor: alertColor,
                                      textColor: ContrastColorOf(alertColor, returnFlat: true),
                                      time: 2, delegate: nil)
            }
        }
        
    }
    
}
