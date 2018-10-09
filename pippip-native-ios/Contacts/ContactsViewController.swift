//
//  ContactsViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/25/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework

class ContactsViewController: UIViewController, ControllerBlurProtocol {


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableBottom: NSLayoutConstraint!
    
    var contactManager = ContactManager.instance
    var config = Configurator()
    var sessionState = SessionState()
    var localAuth: LocalAuthenticator!
    var debugging = false
    var suspended = false
    var alertPresenter = AlertPresenter()
    var contactList: [Contact]!
    var expandedRows: [Bool]!
    var rightBarItems = [UIBarButtonItem]()
    var contactRequests = [ContactRequest]()
    var addContactView: AddContactView?
    var requestsView: ContactRequestsView?
    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = PippipTheme.viewColor
        let frame = self.view.bounds
        blurView.frame = frame
        blurView.alpha = 0.0
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurView)

        self.tableView.delegate = self
        self.tableView.dataSource = self

        let nib = UINib(nibName: "SectionFooterView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "SectionFooterView")

        //let footerBounds = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: 25.0)
        //footerView = SectionFooterView(frame: footerBounds)

        localAuth = LocalAuthenticator(viewController: self, initial: false)

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

        localAuth.viewWillAppear()
        alertPresenter.present = true
        NotificationCenter.default.addObserver(self, selector: #selector(requestsUpdated(_:)),
                                               name: Notifications.RequestsUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(requestStatusUpdated(_:)),
                                               name: Notifications.RequestStatusUpdated, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(localAuthComplete(_:)),
        //                                       name: Notifications.LocalAuthComplete, object: nil)

        if config.showIgnoredContacts {
            contactList = contactManager.contactList
        }
        else {
            contactList = contactManager.visibleContactList
        }
        expandedRows = Array<Bool>(repeating: false, count: contactList.count)
        contactRequests = Array(contactManager.pendingRequests)
        tableView.reloadData()
        DispatchQueue.global().async {
            if self.config.statusUpdates > 0 {
                let suffix: String = self.config.statusUpdates > 1 ? "updates" : "update"
                let message = "You have \(self.config.statusUpdates) contact status \(suffix)"
                self.alertPresenter.infoAlert(title: "Contact Status Updates", message: message)
            }
            self.config.statusUpdates = 0
            NotificationCenter.default.post(name: Notifications.SetContactBadge, object: nil)
        }

    }

    override func viewWillDisappear(_ animated: Bool) {

        alertPresenter.present = false

        NotificationCenter.default.removeObserver(self, name: Notifications.RequestsUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.RequestStatusUpdated, object: nil)

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        localAuth.viewDidDisappear()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
/*
    func acknowledgeRequest(_ contactRequest: ContactRequest) {

        let frame = self.view.bounds
        let viewRect = CGRect(x: 0.0, y: 0.0, width: frame.width * 0.8, height: frame.height * 0.6)
        acknowledgeRequestView = AcknowledgeRequestView(frame: viewRect)
        let viewCenter = CGPoint(x: self.view.center.x, y: self.view.center.y - 30)
        acknowledgeRequestView?.center = viewCenter
        acknowledgeRequestView?.alpha = 0.3
        
        acknowledgeRequestView?.contactsViewController = self
        acknowledgeRequestView?.contactRequest = contactRequest

        self.view.addSubview(self.acknowledgeRequestView!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.acknowledgeRequestView?.alpha = 1.0
            self.blurView.alpha = 0.6
        }, completion: nil)
        
    }
*/
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
                addContactView?.dismiss(completion: { completed in
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
//        let paths = [IndexPath(row: index, section: 1)]
        contactList.remove(at: index)
        expandedRows.remove(at: index)
        DispatchQueue.main.async {
            self.tableView.reloadData()
//            self.tableView.deleteRows(at: paths, with: .bottom)
            self.alertPresenter.infoAlert(title: "Contact Deleted",
                                          message: "This contact has been removed from your list")
        }
        
    }

    @objc func contactRequested(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.DirectoryIdMatched, object: nil)

        DispatchQueue.main.async {
            guard let contact = notification.object as? Contact else { return }
//            let paths = [IndexPath(row: self.contactList.count, section: 1)]
            self.contactList.append(contact)
            self.expandedRows.append(false)
            self.tableView.reloadData()
//            self.tableView.insertRows(at: paths, with: .bottom)
            self.alertPresenter.successAlert(title: "Contact Added",
                                             message: "This contact has been added to your contacts list")
        }
  
    }

    // Debug only
    @objc func deleteContact(_ sender: Any) {
/*
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
*/
    }

    @objc func directoryIdMatched(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.DirectoryIdMatched, object: nil)

        guard let response = notification.object as? MatchDirectoryIdResponse else { return }
        if response.result == "found" {
            DispatchQueue.main.async {
                self.addContactView?.dismiss(completion: { comleted in
                    self.contactManager.requestContact(publicId: response.publicId!,
                                                       directoryId: response.directoryId!,
                                                       retry: false)
                })
            }
        }
        else {
            alertPresenter.errorAlert(title: "Add Contact Error", message: "That directory ID doesn't exist")
        }
        
    }

    @objc func requestAcknowledged(_ notification: Notification) {

        guard let contact = notification.object as? Contact else { return }
        contactList.append(contact)
        expandedRows.append(false)
        contactRequests = Array(contactManager.pendingRequests)
        DispatchQueue.main.async {
            self.tableView.reloadData()
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
                self.tableView.reloadData()
//                self.tableView.reloadRows(at: paths, with: .none)
            }
        }

    }

    @objc func addContact(_ item: Any) {

        let frame = self.view.bounds
        let viewRect = CGRect(x: 0.0, y: 0.0, width: frame.width * 0.8, height: frame.height * 0.45)
        addContactView = AddContactView(frame: viewRect)
        let viewCenter = CGPoint(x: self.view.center.x, y: self.view.center.y - 30)
        addContactView?.center = viewCenter
        addContactView?.alpha = 0.3
        
        addContactView?.contactsViewController = self

        self.view.addSubview(self.addContactView!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView.alpha = 0.6
            self.addContactView?.alpha = 1.0
        }, completion: { complete in
            self.addContactView?.directoryIdTextField.becomeFirstResponder()
        })
        
    }
/*
    @objc func localAuthComplete(_ notification: Notification) {
        
        DispatchQueue.main.async {
            self.localAuth.showAuthView = false
        }
        
    }
*/
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

        return 1

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        var rowCount = contactList.count
        if contactRequests.count > 0 {
            rowCount = rowCount + 1
        }
        return rowCount

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if contactRequests.count > 0 && indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PendingRequestsCell", for: indexPath)
                as? PendingRequestsCell else { return UITableViewCell() }
            //cell.setMediumTheme()
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactDetailCell", for: indexPath)
                as? ContactDetailCell else { return UITableViewCell() }
            cell.setMediumTheme()
            let increment = contactRequests.count > 0 ? 1 : 0
            cell.configure(contact: contactList[indexPath.row - increment], expanded: expandedRows[indexPath.row - increment])
            return cell
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if contactRequests.count > 0 && indexPath.row == 0 {
            return 60.0
        }
        else {
            let increment = contactRequests.count > 0 ? 1 : 0
            if expandedRows[indexPath.row - increment] {
                let contact = contactList[indexPath.row + increment]
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

    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        if contactRequests.count > 0  && indexPath.row == 0{
            return false
        }
        else {
            return true
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if contactRequests.count > 0 && indexPath.row == 0 {
            let frame = self.view.bounds
            let viewRect = CGRect(x: 0.0, y: 0.0, width: frame.width * 0.8, height: frame.height * 0.7)
            requestsView = ContactRequestsView(frame: viewRect)
            requestsView!.blurController = self
            requestsView!.contactRequests = contactRequests
            requestsView!.alpha = 0.0
            requestsView!.center = self.view.center
            self.view.addSubview(requestsView!)
            UIView.animate(withDuration: 0.3, animations: {
                self.blurView.alpha = 0.6
                self.requestsView!.alpha = 1.0
            }, completion: nil)
        }
        else {
            let increment = contactRequests.count > 0 ? 1 : 0
            expandedRows[indexPath.row - increment] = !expandedRows[indexPath.row - increment]
            tableView.reloadRows(at: [indexPath], with: .left)
        }

    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let increment = contactRequests.count > 0 ? 1 : 0
            contactManager.deleteContact(publicId: contactList[indexPath.row - increment].publicId)
        }
        
    }
 
}
