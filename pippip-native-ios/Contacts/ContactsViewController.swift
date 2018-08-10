//
//  ContactsViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/25/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import PMAlertController
import ChameleonFramework

class ContactsViewController: UIViewController {


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableBottom: NSLayoutConstraint!
    
    var contactManager = ContactManager()
    var config = Configurator()
    var sessionState = SessionState()
    var localAuth: LocalAuthenticator!
    var debugging = false
    var suspended = false
    var alertPresenter = AlertPresenter()
    var contactList: [Contact]!
    var expandedRows: [Bool]!
    var rightBarItems = [UIBarButtonItem]()
    var contactRequests: [ContactRequest]!
    var showRequests = false
    var headerView: UIView!
    var addContactView: AddContactView?
    var dimView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = PippipTheme.viewColor
        let frame = self.view.bounds
        dimView = UIView(frame: frame)
        dimView?.backgroundColor = UIColor.flatGray
        dimView?.alpha = 0.0
        self.view.addSubview(dimView!)

        self.tableView.delegate = self
        self.tableView.dataSource = self

        let headerFrame = CGRect(x: 0.0, y:0.0, width: self.view.frame.size.width, height:5.0)
        headerView = UIView(frame: headerFrame)
        headerView.backgroundColor = .clear

        localAuth = LocalAuthenticator(viewController: self, view: self.view)

        let addContact = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContact(_:)))
        rightBarItems.append(addContact)
        let editContacts = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editContacts(_:)))
        rightBarItems.append(editContacts)
        /*
        let deleteItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteContact(_:)))
        rightBarItems.append(deleteItem)
         */
        self.navigationItem.rightBarButtonItems = rightBarItems
        self.navigationItem.title = "Contacts"

        NotificationCenter.default.addObserver(self, selector: #selector(contactRequested(_:)),
                                               name: Notifications.ContactRequested, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contactDeleted(_:)),
                                               name: Notifications.ContactDeleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(requestAcknowledged(_:)),
                                               name: Notifications.RequestAcknowledged, object: nil)

    }

    override func viewWillAppear(_ animated: Bool) {

        localAuth.listening = true
        alertPresenter.present = true
        NotificationCenter.default.addObserver(self, selector: #selector(requestsUpdated(_:)),
                                               name: Notifications.RequestsUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(requestStatusUpdated(_:)),
                                               name: Notifications.RequestStatusUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(localAuthComplete(_:)),
                                               name: Notifications.LocalAuthComplete, object: nil)

        contactList = contactManager.contactList
        expandedRows = Array<Bool>(repeating: false, count: contactList.count)
        contactRequests = Array(contactManager.pendingRequests)
        tableView.reloadData()

    }

    override func viewWillDisappear(_ animated: Bool) {

        localAuth.listening = false
        alertPresenter.present = false

        NotificationCenter.default.removeObserver(self, name: Notifications.RequestsUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.RequestStatusUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.LocalAuthComplete, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func acknowledgeRequest(_ contactRequest: ContactRequest) {

        let name = contactRequest.directoryId ?? contactRequest.publicId
        let alert = PMAlertController(title: "New Contact Request",
                                      description: "New contact request from \(name)",
                                      image: nil,
                                      style: PMAlertControllerStyle.alert)
        alert.addAction(PMAlertAction(title: "Accept",
                                      style: .default, action: { () in
                                        self.contactManager.acknowledgeRequest(contactRequest: contactRequest,
                                                                               response: "accept")
        }))
        alert.addAction(PMAlertAction(title: "Reject",
                                      style: .default, action: { () in
                                        self.contactManager.acknowledgeRequest(contactRequest: contactRequest,
                                                                               response: "reject")
        }))
        alert.addAction(PMAlertAction(title: "Delete",
                                      style: .default, action: { () in
                                        self.contactManager.acknowledgeRequest(contactRequest: contactRequest,
                                                                               response: "ignore")
        }))
        alert.addAction(PMAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true, completion: nil)

    }

    func validateAndRequest(publicId: String, directoryId: String) {
        
        if directoryId == config.directoryId || publicId == sessionState.publicId {
            alertPresenter.errorAlert(title: "Add Contact Error", message: "Adding yourself is not allowed")
        }
        else if directoryId.utf8.count > 0 {
            NotificationCenter.default.addObserver(self, selector: #selector(directoryIdMatched(_:)),
                                                   name: Notifications.DirectoryIdMatched, object: nil)
            self.contactManager.matchDirectoryId(directoryId: directoryId, publicId: nil)
        }
        else if publicId.utf8.count > 0 {
            let regex = try! NSRegularExpression(pattern: "[^A-Fa-f0-9]", options: [])
            if let match = regex.firstMatch(in: publicId,
                                            options: [],
                                            range: NSMakeRange(0, publicId.utf8.count)) {
                if match.numberOfRanges > 0 || publicId.utf8.count < 40 {
                    alertPresenter.errorAlert(title: "Contact Request Error", message: "Not a valid public ID")
                }
            }
            else {
                addContactView?.dismiss(completion: { comleted in
                    self.contactManager.requestContact(publicId: publicId, directoryId: nil, retry: false)
                })
            }
        }

    }

    @objc func editContacts(_ sender: Any) {

        tableView.setEditing(true, animated: true)
        rightBarItems.removeLast()
        let endEdit = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endEditContacts(_:)))
        rightBarItems.append(endEdit)
        self.navigationItem.rightBarButtonItems = rightBarItems
        
    }
    
    @objc func endEditContacts(_ sender: Any) {
        
        tableView.setEditing(false, animated: true)
        rightBarItems.removeLast()
        let editContacts = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editContacts(_:)))
        rightBarItems.append(editContacts)
        self.navigationItem.rightBarButtonItems = rightBarItems
        
    }

    @objc func contactDeleted(_ notification: Notification) {

        guard let publicId = notification.object as? String else { return }
        var index: Int = -1
        for i in 0..<contactList.count {
            if contactList[i].publicId == publicId {
                index = i
            }
        }
        assert(index >= 0)
        let paths = [IndexPath(row: index, section: 1)]
        contactList.remove(at: index)
        expandedRows.remove(at: index)
        DispatchQueue.main.async {
            self.tableView.deleteRows(at: paths, with: .bottom)
            self.alertPresenter.infoAlert(title: "Contact Deleted",
                                          message: "This contact has been removed from your list")
        }
        
    }

    @objc func contactRequested(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.DirectoryIdMatched, object: nil)

        DispatchQueue.main.async {
            guard let contact = notification.object as? Contact else { return }
            let paths = [IndexPath(row: self.contactList.count, section: 1)]
            self.contactList.append(contact)
            self.expandedRows.append(false)
            self.tableView.insertRows(at: paths, with: .bottom)
            self.alertPresenter.successAlert(title: "Contact Added",
                                             message: "This contact has been added to your contacts list")
        }
  
    }

    // Debug only
    @objc func deleteContact(_ sender: Any) {

        let alert = PMAlertController(title: "Delete A Server Contact",
                                      description: "Enter a directory ID or public ID",
                                      image: nil,
                                      style: PMAlertControllerStyle.alert)
        alert.addTextField({ (textField) in
            textField?.placeholder = "Directory ID"
            textField?.autocorrectionType = .no
            textField?.spellCheckingType = .no
        })
        alert.addAction(PMAlertAction(title: "Delete",
                                      style: .default, action: { () in
                                        self.contactManager.deleteServerContact(directoryId: alert.textFields[0].text ?? "")
        }))
        alert.addAction(PMAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true, completion: nil)
        
    }

    @objc func directoryIdMatched(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.DirectoryIdMatched, object: nil)

        guard let response = notification.object as? MatchDirectoryIdResponse else { return }
        if response.result == "found" {
            addContactView?.dismiss(completion: { comleted in
                self.contactManager.requestContact(publicId: response.publicId!,
                                                   directoryId: response.directoryId!,
                                                   retry: false)
            })
        }
        else {
            alertPresenter.errorAlert(title: "Add Contact Error", message: "That directory ID doesn't exist")
        }
        
    }

    @objc func requestAcknowledged(_ notification: Notification) {

        guard let contact = notification.object as? Contact else { return }
        let paths = [IndexPath(row: contactList.count, section: 1)]
        contactList.append(contact)
        expandedRows.append(false)
        DispatchQueue.main.async {
            self.tableView.insertRows(at: paths, with: .left)
            // This has to happen after the contact is inserted
            self.contactRequests = Array(self.contactManager.pendingRequests)
            self.tableView.reloadSections(IndexSet(integer: 0), with: .left)
        }
        
    }

    @objc func requestsUpdated(_ notification: Notification) {

        contactRequests = Array(contactManager.pendingRequests)
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: 0), with: .left)
        }

    }

    @objc func requestStatusUpdated(_ notification: Notification) {

        guard let updates = notification.object as? [Contact] else { return }
        var paths = [IndexPath]()
        for updated in updates {
            for index in 0..<contactList.count {
                let contact = contactList[index]
                if contact.publicId == updated.publicId {
                    paths.append(IndexPath(row: index, section: 1))
                }
            }
        }
        if !paths.isEmpty {
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: paths, with: .none)
            }
        }

    }

    @objc func addContact(_ item: Any) {

/*
        let alert = PMAlertController(title: "Add A New Contact",
                                      description: "Enter a directory ID or public ID",
                                      image: nil,
                                      style: PMAlertControllerStyle.alert)
        alert.addTextField({ (textField) in
            textField?.placeholder = "Directory ID"
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
                                        self.validateAndRequest(publicId: alert.textFields[1].text,
                                                                directoryId: alert.textFields[0].text)
        }))
        alert.addAction(PMAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true, completion: nil)
*/

        let frame = self.view.bounds
        let viewRect = CGRect(x: 0.0, y: 0.0, width: frame.width * 0.8, height: frame.height * 0.45)
        addContactView = AddContactView(frame: viewRect)
        let viewCenter = CGPoint(x: self.view.center.x, y: self.view.center.y - 30)
        addContactView?.center = viewCenter
        addContactView?.alpha = 0.3
        
        addContactView?.contactsViewController = self

        self.view.addSubview(self.addContactView!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.dimView?.alpha = 0.55
            self.addContactView?.alpha = 1.0
        }, completion: { complete in
            self.addContactView?.directoryIdTextField.becomeFirstResponder()
        })
        
    }

    @objc func localAuthComplete(_ notification: Notification) {
        
        DispatchQueue.main.async {
            self.localAuth.visible = false
        }
        
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

extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        return 2

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            var rowCount = 0
            if contactRequests.count > 0 {
                rowCount = showRequests ? contactRequests.count + 1 : 1
            }
            return rowCount
        }
        else {
            return contactList.count
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            assert(contactRequests.count > 0)
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "PendingRequestsCell", for: indexPath)
                    as? PippipTableViewCell else { return UITableViewCell() }
                cell.setMediumTheme()
                cell.textLabel?.textColor = PippipTheme.buttonMediumTextColor
                return cell
            }
            else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "PendingRequestCell", for: indexPath)
                    as? PendingRequestCell else { return UITableViewCell() }
                cell.setLightTheme()
                let request = contactRequests[indexPath.row-1]
                cell.directoryIdLabel.text = request.directoryId
                cell.publicIdLabel.text = request.publicId
                return cell
            }
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactDetailCell", for: indexPath)
                as? ContactDetailCell else { return UITableViewCell() }
            cell.setMediumTheme()
            cell.configure(contact: contactList[indexPath.row], expanded: expandedRows[indexPath.row])
            return cell
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.section == 0 {
            return indexPath.row == 0 ? 55.0 : 65.0
        }
        else if expandedRows[indexPath.row] {
            let contact = contactList[indexPath.row]
            if contact.status == "pending" {
                return 150.0
            }
            else {
                return 105.0
            }
        }
        else {
            return 60.0
        }

    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        return indexPath.section != 0

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                showRequests = !showRequests
                tableView.reloadSections(IndexSet(integer: 0), with: .left)
            }
            else {
                let contactRequest = contactRequests[indexPath.row-1]
                acknowledgeRequest(contactRequest)
            }
        }
        else {
            expandedRows[indexPath.row] = !expandedRows[indexPath.row]
            tableView.reloadRows(at: [indexPath], with: .left)
        }

    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            contactManager.deleteContact(publicId: contactList[indexPath.row].publicId)
        }
        
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        return headerView

    }

 }
