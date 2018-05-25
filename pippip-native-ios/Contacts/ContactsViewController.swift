//
//  ContactsViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/25/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import PMAlertController
import RKDropdownAlert
import ChameleonFramework

class ContactsViewController: UIViewController, RKDropdownAlertDelegate {


    @IBOutlet weak var tableView: ExpandingTableView!
    @IBOutlet weak var tableBottom: NSLayoutConstraint!
    
    var contactManager = ContactManager()
    var contactsModel = ContactsTableModel()
    var config = Configurator()
    var sessionState = SessionState()
    var localAuth: LocalAuthenticator!
    var nickname: String?
    var publicId = ""
    var debugging = false
    var suspended = false
    var alertPresenter = AlertPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.expandingModel = contactsModel
        self.view.backgroundColor = PippipTheme.viewColor

        let headerFrame = CGRect(x: 0.0, y:0.0, width: self.view.frame.size.width, height:40.0)
        contactsModel.headerViews[1] = ContactsHeaderView(headerFrame)

        localAuth = LocalAuthenticator(viewController: self, view: self.view)

        var items = [UIBarButtonItem]()
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContact(_:)))
        items.append(addItem)
        if (debugging) {
            let deleteItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteContact(_:)))
            items.append(deleteItem)
        }
        self.navigationItem.rightBarButtonItems = items
        self.navigationItem.title = "Contacts"

    }

    override func viewWillAppear(_ animated: Bool) {

        localAuth.listening = true
        alertPresenter.present = true
        NotificationCenter.default.addObserver(self, selector: #selector(requestsUpdated(_:)),
                                               name: Notifications.RequestsUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(thumbprintComplete(_:)),
                                               name: Notifications.ThumbprintComplete, object: nil)

        contactsModel.setContacts(contactList: contactManager.getContactList(), viewController: self)
        let pendingRequests = Array(contactManager.pendingRequests)
        if pendingRequests.count > 0 {
            contactsModel.setPendingRequests(pendingRequests: pendingRequests, viewController: self)
        }

    }

    override func viewWillDisappear(_ animated: Bool) {

        localAuth.listening = false
        alertPresenter.present = false
        
        tableView.collapseAll(section: 0)
        tableView.collapseAll(section: 1)

        NotificationCenter.default.removeObserver(self, name: Notifications.RequestsUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.ThumbprintComplete, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func contactRequested(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.NicknameMatched, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.ContactRequested, object: nil)

        DispatchQueue.main.async {
            let contact = notification.object as! Contact
            let cells = self.contactsModel.createCells(cellId: "ContactCell", count: 1)
            guard let cell = cells[0] as? ContactCell else { return }
            cell.contact = contact
            cell.setMediumTheme()
            self.contactsModel.addChildren(cell: cell, contact: contact)
            self.contactsModel.appendExpandingCell(cell: cell, section: 1, animation: .left)
            
            self.alertPresenter.successAlert(title: "Contact Added",
                                             message: "This contact has been added to your contacts list")
        }
        
    }

    @objc func deleteContact(_ sender: Any) {

        let alert = PMAlertController(title: "Delete A Server Contact",
                                      description: "Enter a nickname or public ID",
                                      image: nil,
                                      style: PMAlertControllerStyle.alert)
        alert.addTextField({ (textField) in
            textField?.placeholder = "Nickname"
            textField?.autocorrectionType = .no
            textField?.spellCheckingType = .no
        })
        alert.addAction(PMAlertAction(title: "Delete",
                                      style: .default, action: { () in
                                        self.nickname = alert.textFields[0].text ?? ""
                                        self.contactManager.deleteServerContact(nickname: self.nickname!)
        }))
        alert.addAction(PMAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true, completion: nil)
        
    }

    @objc func nicknameMatched(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.NicknameMatched, object: nil)

        let info = notification.userInfo!
        if let puid = info["publicId"] as? String {
            publicId = puid
            nickname = info["nickname"] as? String ?? ""
            contactManager.requestContact(publicId: publicId, nickname: nickname, retry: false)
        }
        else {
            DispatchQueue.main.async {
                let alertColor = UIColor.flatSand
                RKDropdownAlert.title("Add Contact Error", message: "That nickname doesn't exist",
                                      backgroundColor: alertColor,
                                      textColor: ContrastColorOf(alertColor, returnFlat: true),
                                      time: 2, delegate: nil)
                NotificationCenter.default.removeObserver(self, name: Notifications.ContactRequested, object: nil)
           }
        }
        
    }
    
    @objc func requestsUpdated(_ notification: Notification) {

        guard let requestCount = notification.object as? Int else { return }
        if requestCount > 0 {
            // We want a copy
            DispatchQueue.main.async {
                let cell = self.contactsModel.getCell(indexPath: IndexPath(row: 0, section: 0)) as! ContactCell
                let selector = cell.selector as! PendingRequestsSelector
                selector.updateRequests(requests: Array(self.contactManager.pendingRequests))
            }
        }
        else {
            DispatchQueue.main.async {
                self.tableView.expandingModel?.clear(section: 0)
            }
        }

    }

    @objc func addContact(_ item: Any) {

        NotificationCenter.default.addObserver(self, selector: #selector(contactRequested(_:)),
                                               name: Notifications.ContactRequested, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(nicknameMatched(_:)),
                                               name: Notifications.NicknameMatched, object: nil)

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
                                        if self.nickname == self.config.nickname
                                            || self.publicId == self.sessionState.publicId {
                                            self.alertPresenter.errorAlert(title: "Add Contact Error",
                                                                           message: "Adding yourself is not allowed")
                                        }
                                        else if self.nickname!.utf8.count > 0 {
                                            self.contactManager.matchNickname(nickname: self.nickname, publicId: nil)
                                        }
                                        else if self.publicId.utf8.count > 0 {
                                            self.contactManager.requestContact(publicId: self.publicId, nickname: nil, retry: false)
                                        }
        }))
        alert.addAction(PMAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true, completion: nil)

    }

    @objc func thumbprintComplete(_ notification: Notification) {
        
        DispatchQueue.main.async {
            self.localAuth.visible = false
        }
        
    }
    
    func dropdownAlertWasTapped(_ alert: RKDropdownAlert!) -> Bool {
        return true
    }
    
    func dropdownAlertWasDismissed() -> Bool {
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
