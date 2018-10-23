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
    var alertPresenter: AlertPresenter!
    var contactList: [Contact]!
    var rightBarItems = [UIBarButtonItem]()
    var contactRequests = [ContactRequest]()
    var addContactView: AddContactView?
    var contactDetailView: ContactDetailView?
    var requestsView: ContactRequestsView?
    var blurView = GestureBlurView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))

    override func viewDidLoad() {
        super.viewDidLoad()

        alertPresenter = AlertPresenter(view: self.view)
        self.view.backgroundColor = PippipTheme.viewColor
        let frame = self.view.bounds
        blurView.frame = frame
        blurView.alpha = 0.0
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurView)

        self.tableView.delegate = self
        self.tableView.dataSource = self

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
        NotificationCenter.default.addObserver(self, selector: #selector(appSuspended(_:)),
                                               name: Notifications.AppSuspended, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(directoryIdSet(_:)),
                                               name: Notifications.DirectoryIdSet, object: nil)

        if config.showIgnoredContacts {
            contactList = contactManager.contactList
        }
        else {
            contactList = contactManager.visibleContactList
        }
        contactRequests = Array(contactManager.pendingRequests)
        tableView.reloadData()
        DispatchQueue.global().async {
            if self.config.statusUpdates > 0 {
                let suffix: String = self.config.statusUpdates > 1 ? "updates" : "update"
                let message = "You have \(self.config.statusUpdates) contact status \(suffix)"
                self.alertPresenter.infoAlert(message: message)
            }
            self.config.statusUpdates = 0
            NotificationCenter.default.post(name: Notifications.SetContactBadge, object: nil)
        }

    }

    override func viewWillDisappear(_ animated: Bool) {

        alertPresenter.present = false
        addContactView?.dismiss(completion: nil)
        contactDetailView?.dismiss()
        NotificationCenter.default.removeObserver(self, name: Notifications.RequestsUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.RequestStatusUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.AppSuspended, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.DirectoryIdSet, object: nil)

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        localAuth.viewDidDisappear()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                addContactView?.dismiss(completion: { completed in
                    self.contactManager.requestContact(publicId: publicId, directoryId: nil, retry: false)
                })
            }
        }

    }

    func showContactDetailView(contact: Contact) {
        
        let frame = self.view.bounds
        var heightRatio = PippipGeometry.contactDetailViewNoRetryRatio
        if contact.status == "pending" {
            heightRatio = PippipGeometry.contactDetailViewHeightRatio
        }
        let viewRect = CGRect(x: 0.0, y: 0.0,
                              width: frame.width * PippipGeometry.contactDetailViewWidthRatio,
                              height: frame.height * heightRatio!)
        contactDetailView = ContactDetailView(frame: viewRect)
        contactDetailView?.setDetail(contact: contact)
        let viewCenter = CGPoint(x: self.view.center.x, y: self.view.center.y - PippipGeometry.contactDetailViewOffset)
        contactDetailView?.center = viewCenter
        contactDetailView?.alpha = 0.0
        
        contactDetailView?.blurController = self
        
        blurView.toDismiss = contactDetailView
        self.view.addSubview(contactDetailView!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView.alpha = 0.6
            self.contactDetailView?.alpha = 1.0
        }, completion: { complete in
        })
        
    }
    
    func showContactRequestsView() {
        
        let frame = self.view.bounds
        let viewRect = CGRect(x: 0.0, y: 0.0,
                              width: frame.width * PippipGeometry.contactRequestsViewWidthRatio,
                              height: frame.height * PippipGeometry.contactRequestsViewHeightRatio)
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

    @objc func appSuspended(_ notification: Notification) {
        
        requestsView?.dismiss()
        contactDetailView?.dismiss()

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
        DispatchQueue.main.async {
            self.contactList.remove(at: index)
            self.tableView.deleteRows(at: [IndexPath(row: index, section: 1)], with: .left)
        }
        
    }

    @objc func contactRequested(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.DirectoryIdMatched, object: nil)

        guard let contact = notification.object as? Contact else { return }
        contactList.append(contact)
        contactList = self.contactList.sorted()
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: 1), with: .top)
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

    @objc func directoryIdSet(_ notification: Notification) {
        
        guard let contact = notification.object as? Contact else { return }
        DispatchQueue.main.async {
            for index in 0..<self.contactList.count {
                if contact.contactId == self.contactList[index].contactId {
                    self.contactList[index] = contact
                    if let contactCell = self.tableView.cellForRow(at: IndexPath(row: index, section: 1)) as? ContactCell {
                        contactCell.displayNameLabel.text = contact.displayName
                    }
                }
            }
        }

    }

    @objc func requestAcknowledged(_ notification: Notification) {

        guard let contact = notification.object as? Contact else { return }
        contactRequests = Array(contactManager.pendingRequests)
        contactList.append(contact)
        contactList = contactList.sorted()
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: 0), with: .top)
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
        for updated in updates {
            for contact in contactList {
                if updated.contactId == contact.contactId {
                    contact.status = updated.status
                }
            }
        }
        contactList = contactList.sorted()
        config.statusUpdates = 0
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: 1), with: .top)
        }

    }

    @objc func addContact(_ item: Any) {

        let frame = self.view.bounds
        let viewRect = CGRect(x: 0.0, y: 0.0,
                              width: frame.width * PippipGeometry.addContactViewWidthRatio,
                              height: frame.height * PippipGeometry.addContactViewHeightRatio)
        addContactView = AddContactView(frame: viewRect)
        let viewCenter = CGPoint(x: self.view.center.x, y: self.view.center.y - PippipGeometry.addContactViewOffset)
        addContactView?.center = viewCenter
        addContactView?.alpha = 0.0
        
        addContactView?.contactsViewController = self

        self.view.addSubview(self.addContactView!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView.alpha = 0.6
            self.addContactView?.alpha = 1.0
        }, completion: { complete in
            self.navigationController?.setNavigationBarHidden(PippipGeometry.addContactViewHideNavBar, animated: true)
            self.addContactView?.directoryIdTextField.becomeFirstResponder()
        })
        
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

//        return contactRequests.count > 0 ? 2 : 1
        return 2

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            return contactRequests.count > 0 ? 1 : 0
        }
        else {
            return contactList.count
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 && contactRequests.count > 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PendingRequestsCell", for: indexPath)
                as? PendingRequestsCell else { return UITableViewCell() }
            return cell
        }
        else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
                as? ContactCell else { return UITableViewCell() }
            cell.setMediumTheme()
            cell.configure(contact: contactList[indexPath.row])
            return cell
        }
        else {
            return UITableViewCell()
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.section == 0 {
            return 60.0
        }
        else {
            return 70.0
        }

    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        return indexPath.section == 1

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 {
            showContactRequestsView()
        }
        else {
            showContactDetailView(contact: contactList[indexPath.row])
        }

    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            contactManager.deleteContact(publicId: contactList[indexPath.row].publicId)
        }
        
    }
 
}
