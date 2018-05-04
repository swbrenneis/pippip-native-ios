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
    var config = Configurator()
    var sessionState = SessionState()
    var authView: AuthViewController?
    var nickname: String?
    var publicId = ""
    var debugDelete = false
    var debugging = false
    var suspended = false
    var pendingRequests = [[AnyHashable: Any]]()
    var pendingCellData: PendingRequestsCellData?

    init() {

        contactManager = ContactManager()
        contactsModel = ContactsTableModel()

        super.init(nibName: nil, bundle: nil)

    }

    required init?(coder aDecoder: NSCoder) {

        contactManager = ContactManager()
        contactsModel = ContactsTableModel()
        
        super.init(coder: aDecoder)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.expandingModel = contactsModel
        let headerFrame = CGRect(x: 0.0, y:0.0, width: self.view.frame.size.width, height:40.0)
        contactsModel.headerViews[1] = ContactsHeaderView(headerFrame)

        authView = self.storyboard?.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController
        authView?.isAuthenticated = true

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

        NotificationCenter.default.addObserver(self, selector: #selector(requestsUpdated(_:)),
                                               name: Notifications.RequestsUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentAlert(_:)),
                                               name: Notifications.PresentAlert, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appResumed(_:)),
                                               name: Notifications.AppResumed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appSuspended(_:)),
                                               name: Notifications.AppSuspended, object: nil)

        contactsModel.setContacts(contactManager.getContactList(), viewController: self)
        tableView.reloadData()
        pendingRequests = contactManager.getContactRequests()
        if pendingRequests.count > 0 {
            pendingCellData = PendingRequestsCellData(pendingRequests, viewController: self)
            tableView.expandingModel!.insertCell(pendingCellData!, section: 0, row: 0)
            tableView.insertRows(at: self.tableView.expandingModel!.insertPaths, with: .top)
        }

    }

    override func viewWillDisappear(_ animated: Bool) {

        NotificationCenter.default.removeObserver(self, name: Notifications.RequestsUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.PresentAlert, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.AppResumed, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.AppSuspended, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func appResumed(_ notification: Notification) {

        if suspended {
            suspended = false
            if let info = notification.userInfo {
                authView?.suspendedTime = (info["suspendedTime"] as! NSNumber).intValue
            }
            DispatchQueue.main.async {
                self.present(self.authView!, animated: true, completion: nil)
            }
            
        }
        
    }
    
    @objc func appSuspended(_ notification: Notification) {

        suspended = true
        DispatchQueue.main.async {
            self.contactsModel.clear(1, tableView: self.tableView)
        }

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
                                        self.contactManager.matchNickname(nickname: self.nickname, publicId: nil)
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
            if (debugDelete) {
                debugDelete = false
                contactManager.deleteContact(publicId)
            }
            else {
                contactManager.requestContact(publicId: publicId, nickname: nickname)
            }
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

        guard let newRequests = notification.object as? Bool else { return }
        if newRequests {
            pendingRequests = contactManager.getContactRequests()
            if pendingCellData == nil {
                DispatchQueue.main.async {
                    self.pendingCellData = PendingRequestsCellData(self.pendingRequests, viewController: self)
                    self.tableView.expandingModel!.insertCell(self.pendingCellData!, section: 0, row: 0)
                    self.tableView.insertRows(at: self.tableView.expandingModel!.insertPaths, with: .top)
                }
            }
            else {
                pendingCellData?.updateRequests(pendingRequests)
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
                                        if self.nickname == self.config.getNickname()
                                            || self.publicId == self.sessionState.publicId {
                                            let alertColor = UIColor.flatSand
                                            RKDropdownAlert.title("Add Contact Error",
                                                                  message: "Adding yourself is not allowed",
                                                                  backgroundColor: alertColor,
                                                                  textColor: ContrastColorOf(alertColor, returnFlat: true),
                                                                  time: 2, delegate: nil)
                                        }
                                        else if self.nickname!.utf8.count > 0 {
                                            self.contactManager.matchNickname(nickname: self.nickname, publicId: nil)
                                        }
                                        else if self.publicId.utf8.count > 0 {
                                            self.contactManager.requestContact(publicId: self.publicId, nickname: nil)
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
