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
    
    var contactManager: ContactManager
    var contactsModel: ContactsTableModel
    var authView: AuthViewController
    var nickname: String?
    var publicId = ""
    var debugDelete = false
    var debugging = true
    var suspended = false

    init() {

        contactManager = ContactManager()
        contactsModel = ContactsTableModel()
        authView = AuthViewController()

        super.init(nibName: nil, bundle: nil)

    }

    required init?(coder aDecoder: NSCoder) {

        contactManager = ContactManager()
        contactsModel = ContactsTableModel()
        authView = AuthViewController()
        
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.expandingModel = contactsModel
        contactsModel.viewController = self
        let headerFrame = CGRect(x: 0.0, y:0.0, width: self.view.frame.size.width, height:40.0)
        contactsModel.headerViews[1] = ContactsHeaderView(headerFrame)

        authView = AuthViewController()
        authView.suspended = true

        var items = [UIBarButtonItem]()
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContact(_:)))
        items.append(addItem)
        if (debugging) {
            let deleteItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteContact(_:)))
            items.append(deleteItem)
        }
        self.navigationItem.rightBarButtonItems = items

        NotificationCenter.default.addObserver(self, selector: #selector(contactsUpdated(_:)),
                                               name: Notifications.ContactsUpdated, object: nil)
/*
        NotificationCenter.default.addObserver(self, selector: #selector(requestAcknowledged(_:)),
                                               name: Notifications.RequestAcknowledged, object: nil)
*/
    }

    override func viewWillAppear(_ animated: Bool) {

        NotificationCenter.default.addObserver(self, selector: #selector(requestsUpdated(_:)),
                                               name: Notifications.RequestsUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentAlert(_:)),
                                               name: Notifications.PresentAlert, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contactRequested(_:)),
                                               name: Notifications.ContactRequested, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(nicknameMatched(_:)),
                                               name: Notifications.NicknameMatched, object: nil)

        contactsModel.setContacts(contactManager.getContactList())
        contactManager.getRequests()

    }

    override func viewWillDisappear(_ animated: Bool) {

        NotificationCenter.default.removeObserver(self, name: Notifications.RequestsUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.PresentAlert, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.NicknameMatched, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.FriendAdded, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func appResumed(_ notification: Notification) {

        if (suspended) {
            suspended = false
            let info = notification.userInfo
            if let suspendedTime = info?[AnyHashable("suspendedTime")] as? NSNumber {
                if (suspendedTime.intValue > 0 && suspendedTime.intValue < 180) {
                    authView.suspended = true
                }
                else {
                    let auth = Authenticator()
                    auth.logout()
                }
                DispatchQueue.main.async {
                    self.present(self.authView, animated: true, completion: nil)
                }
            }
            
        }

    }
    
    @objc func appSuspended(_ notification: Notification) {

        suspended = true
        DispatchQueue.main.async {
            self.contactsModel.clear(1, tableView: self.tableView)
            self.tableView.deleteRows(at: self.contactsModel.deletePaths, with: .top)
        }

    }
    
    @objc func contactsUpdated(_ notification: Notification) {

        DispatchQueue.main.async {
            self.contactsModel.clear(1, tableView: self.tableView)
            let contactList = self.contactManager.getContactList()
            self.contactsModel.setContacts(contactList)
        }
    
    }

    @objc func contactRequested(_ notification: Notification) {

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
                                           contact: contact, viewController: self)
            if let model = self.tableView.expandingModel {
                model.appendCell(cellData, section: 1)
                let alertColor = UIColor.flatLime
                RKDropdownAlert.title("Contact Added", message: "This contact has been added to your contacts list",
                                      backgroundColor: alertColor,
                                      textColor: ContrastColorOf(alertColor, returnFlat: true),
                                      time: 2, delegate: nil)
                self.tableView.insertRows(at: model.insertPaths, with: .right)
            }
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
                                        self.debugDelete = true
                                        self.nickname = alert.textFields[0].text ?? ""
                                        self.contactManager.matchNickname(self.nickname, withPublicId: nil)
        }))
        alert.addAction(PMAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true, completion: nil)
        
    }

    @objc func nicknameMatched(_ notification: Notification) {
        
        let info = notification.userInfo!
        if let puid = info["publicId"] as? String {
            publicId = puid
            nickname = info["nickname"] as? String ?? ""
            if (debugDelete) {
                debugDelete = false
                contactManager.deleteContact(publicId)
            }
            else {
                contactManager.requestContact(publicId, withNickname: nickname)
            }
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
    
    @objc func requestsUpdated(_ notification: Notification) {

        // Notification only happens for non-zero request count
        if let requests = notification.object as? [[AnyHashable: Any]] {
            let count = tableView.expandingModel!.tableModel[0]!.count
            if count == 0 {
                DispatchQueue.main.async {
                    let cellData = PendingRequestsCellData(requests, viewController: self)
                    self.tableView.expandingModel!.insertCell(cellData, section: 0, row: 0)
                    self.tableView.insertRows(at: self.tableView.expandingModel!.insertPaths, with: .top)
                }
            }
        }
        let _ = DispatchQueue.global().asyncAfter(deadline: .now() + 15.0, execute: {
            self.contactManager.getRequests()
            })

    }

    @objc func addContact(_ item: Any) {

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
                                        if self.nickname!.utf8.count > 0 {
                                            self.contactManager.matchNickname(self.nickname, withPublicId: nil)
                                        }
                                        else if self.publicId.utf8.count > 0 {
                                            self.contactManager.requestContact(self.publicId, withNickname: nil)
                                        }
        }))
        alert.addAction(PMAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true, completion: nil)

    }

    @objc func presentAlert(_ notification: Notification) {

        let userInfo = notification.userInfo!
        let title = userInfo["title"] as? String
        let message = userInfo["message"] as? String
        DispatchQueue.main.async {
            let alertColor = UIColor.flatSand
            RKDropdownAlert.title(title, message: message, backgroundColor: alertColor,
                                  textColor: ContrastColorOf(alertColor, returnFlat: true),
                                  time: 2, delegate: self)
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
