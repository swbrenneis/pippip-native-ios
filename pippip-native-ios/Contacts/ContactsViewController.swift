//
//  ContactsViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/25/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework
import CocoaLumberjack

class ContactsViewController: UIViewController, ControllerBlurProtocol, ObserverProtocol {


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableBottom: NSLayoutConstraint!

    var config = Configurator()
    var sessionState = SessionState.instance
    var authenticator: Authenticator!
    var debugging = false
    var alertPresenter: AlertPresenter!
    var contactList = [Contact]()
    var rightBarItems = [UIBarButtonItem]()
    var contactRequests = [ContactRequest]()
    var addContactView: AddContactView?
    var contactDetailView: ContactDetailView?
    var requestsView: ContactRequestsView?
    var messageView: InitialMessageView?
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

        authenticator = Authenticator(viewController: self)

        let addContact = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContact(_:)))
        rightBarItems.append(addContact)
        let editContacts = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editContacts(_:)))
        rightBarItems.append(editContacts)
        #if targetEnvironment(simulator)
        let pollButton = UIBarButtonItem(title: "Poll", style: .plain, target: self, action: #selector(pollServer(_ :)))
        rightBarItems.append(pollButton)
        #endif
        /*
        let deleteItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteContact(_:)))
        rightBarItems.append(deleteItem)
         */
        self.navigationItem.rightBarButtonItems = rightBarItems
        self.navigationItem.title = "Contacts"

        NotificationCenter.default.addObserver(self, selector: #selector(resetControllers(_:)),
                                               name: Notifications.ResetControllers, object: nil)

    }

    override func viewWillAppear(_ animated: Bool) {

        authenticator.viewWillAppear()
        alertPresenter.present = true
        ContactsModel.instance.addObserver(action: .acknowledged, observer: self)
        ContactsModel.instance.addObserver(action: .requestsAdded, observer: self)
        ContactsModel.instance.addObserver(action: .requestDeleted, observer: self)
        NotificationCenter.default.addObserver(self, selector: #selector(contactRequested(_:)),
                                               name: Notifications.ContactRequested, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contactDeleted(_:)),
                                               name: Notifications.ContactDeleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(requestsUpdated(_:)),
                                               name: Notifications.RequestsUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(requestStatusUpdated(_:)),
                                               name: Notifications.RequestStatusUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appSuspended(_:)),
                                               name: Notifications.AppSuspended, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(directoryIdSet(_:)),
                                               name: Notifications.DirectoryIdSet, object: nil)

        setContactList()
        contactRequests = Array(ContactsModel.instance.pendingRequests)
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
        authenticator.viewWillDisappear()
        addContactView?.dismiss()
        contactDetailView?.forceDismiss()
        ContactsModel.instance.removeObserver(action: .acknowledged, observer: self)
        ContactsModel.instance.removeObserver(action: .requestsAdded, observer: self)
        ContactsModel.instance.removeObserver(action: .requestDeleted, observer: self)
        NotificationCenter.default.removeObserver(self, name: Notifications.ContactRequested, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.ContactDeleted, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.RequestsUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.RequestStatusUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.AppSuspended, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.DirectoryIdSet, object: nil)

    }
/*
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        localAuth.viewDidDisappear()
        
    }
*/
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func contactAcknowledged(contact: Contact) {

        assert(Thread.isMainThread)
        if config.showIgnoredContacts || contact.status != "ignored" {
            contactList.append(contact)
            contactList = contactList.sorted()
            guard let row = contactList.firstIndex(of: contact) else { return }
            tableView.insertRows(at: [IndexPath(row: row, section: 0)], with: .left)
        }
        
    }
    
    func requestsUpdated() {
/*
        assert(Thread.isMainThread)
        // Do these in order because both sections are validated after inserts and deletes to any section
        let newRequests = Array(ContactsModel.instance.pendingRequests)

        if newRequests.count == 0 {
            contactRequests = newRequests
            // Check to see if section 0 is visible
            var requestSectionVisible = false
            if let paths = tableView.indexPathsForVisibleRows {
                for path in paths {
                    if path.section == 0 {
                        requestSectionVisible = true
                    }
                }
            }
            // Clear the section if the request list is empty
            if requestSectionVisible {
                tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .right)
            }
        }
        else if contactRequests.count == 0 {
            contactRequests = newRequests
            // Insert the requests button row
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .left)
        }
        else {
            contactRequests = newRequests
        }
*/
    }
    
    func setContactList() {
        
        let contactsModel = ContactsModel.instance
        contactList.removeAll()
        if config.showIgnoredContacts {
            contactList.append(contentsOf: contactsModel.allContacts)
        }
        else {
            contactList.append(contentsOf: contactsModel.pendingContactList)
            contactList.append(contentsOf: contactsModel.acceptedContactList)
            contactList.append(contentsOf: contactsModel.rejectedContactList)
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
        contactDetailView?.contactsViewController = self
        contactDetailView?.setDetail(contact: contact)
        let viewCenter = CGPoint(x: self.view.center.x, y: self.view.center.y - PippipGeometry.contactDetailViewOffset)
        contactDetailView?.center = viewCenter
        contactDetailView?.alpha = 0.0
        
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
        requestsView!.contactsViewController = self
        requestsView!.contactRequests = contactRequests
        requestsView!.alpha = 0.0
        requestsView!.center = self.view.center

        self.view.addSubview(requestsView!)

        UIView.animate(withDuration: 0.3, animations: {
            self.blurView.alpha = 0.6
            self.requestsView!.alpha = 1.0
        }, completion: { complete in
            self.messageView?.messageTextView.becomeFirstResponder()
        })

    }

    func showInitialMessageView(publicId: String?, directoryId: String?) {
        
        let frame = self.view.bounds
        let viewRect = CGRect(x: 0.0, y: 0.0,
                              width: frame.width * 0.9,
                              height: frame.height * 0.4)
        messageView = InitialMessageView(frame: viewRect)
        messageView!.contactsViewController = self
        messageView!.directoryId = directoryId
        messageView!.publicId = publicId
        let viewCenter = CGPoint(x: self.view.center.x, y: self.view.center.y - 60.0)
        messageView!.center = viewCenter
        messageView!.alpha = 0.0
        
        blurView.toDismiss = messageView
        self.view.addSubview(messageView!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.messageView!.alpha = 1.0
        }, completion: { complete in
        })
        
    }
    
    func update(observable: ObservableProtocol, object: Any?) {
        
        if let contactAction = object as? ObservedContactAction {
            DispatchQueue.main.async {
                switch contactAction {
                case .added:
                    break
                case .deleted:
                    break
                case .acknowledged(let contact):
                    self.contactAcknowledged(contact: contact)
                    break
                case .requestsAdded:
                    self.requestsUpdated()
                    break
                case .requestsDeleted:
                    self.requestsUpdated()
                    break
                }
            }
        }
    }
/*
    func validateAndRequest(publicId: String, directoryId: String) {
        
        addContactView?.dismiss()
        if directoryId == config.directoryId || publicId == sessionState.publicId {
            alertPresenter.errorAlert(title: "Add Contact Error", message: "Adding yourself is not allowed")
        }
        else if ContactsModel.instance.contactRequestExists(publicId: publicId, directoryId: directoryId) {
            alertPresenter.errorAlert(title: "Add Contact Error", message: "There is an existing request for that contact")
        }
        else if directoryId.count > 0 {
            let directoryManager = DirectoryManager()
            directoryManager.matchDirectoryId(directoryId: directoryId, publicId: nil,
                                              onResponse: { response -> Void in
                                                self.directoryIdMatched(response: response)
            },
                                              onError: { error in
                                                DDLogError("Match directory ID error: \(error)")
            })
        }
        else if publicId.count > 0 {
            if let _ = ContactsModel.instance.getContact(publicId: publicId) {
                alertPresenter.errorAlert(title: "Add Contact Error", message: "That contact is already in your list")
            }
            else {
                do {
                    let contactManager = ContactManager()
                    try contactManager.requestContact(publicId: publicId, directoryId: nil, retry: false)
                }
                catch {
                    DDLogError("Error sending contact request: \(error.localizedDescription)")
                    alertPresenter.errorAlert(title: "Contact Request Error", message: "The request could not be sent")
                }
            }
        }
        
    }
*/
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

    #if targetEnvironment(simulator)
    @objc func pollServer(_ sender: Any) {
        AccountSession.instance.doUpdates()
    }
    #endif
    
    // Notifications
    
    @objc func appSuspended(_ notification: Notification) {
        
        requestsView?.dismiss()
        contactDetailView?.dismiss()
        addContactView?.dismiss()

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
            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .left)
        }
        
    }

    @objc func contactRequested(_ notification: Notification) {

        guard let contact = notification.object as? Contact else { return }
        contactList.append(contact)
        contactList = self.contactList.sorted()
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: 1), with: .top)
        }
  
    }

    func directoryIdMatched(response: MatchDirectoryIdResponse) {
/*
        DispatchQueue.main.async {
            self.addContactView?.dismiss()
        }
        if response.result == "found" {
            guard let publicId = response.publicId else { return }
            if let _ = ContactsModel.instance.getContact(publicId: publicId) {
                alertPresenter.errorAlert(title: "Add Contact Error", message: "That contact is already in your list")
            }
            else if ContactsModel.instance.contactRequestExists(publicId, directoryId: <#String?#>) {
                alertPresenter.errorAlert(title: "Add Contact Error", message: "There is an existing request for that contact")
            }
            else {
                do {
                    let contactManager = ContactManager()
                    try contactManager.requestContact(publicId: publicId, directoryId: response.directoryId, retry: false)
                }
                catch {
                    DDLogError("Error sending contact request: \(error.localizedDescription)")
                    alertPresenter.errorAlert(title: "Request Contact Error", message: "The request could not be sent")
                }
            }
        }
        else {
            alertPresenter.errorAlert(title: "Add Contact Error", message: "That directory ID doesn't exist")
        }
*/
    }

    @objc func directoryIdSet(_ notification: Notification) {
        
        guard let contact = notification.object as? Contact else { return }
        DispatchQueue.main.async {
            for index in 0..<self.contactList.count {
                if contact.contactId == self.contactList[index].contactId {
                    self.contactList[index] = contact
                    if let contactCell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ContactCell {
                        contactCell.displayNameLabel.text = contact.displayName
                    }
                }
            }
        }

    }

    @objc func requestsUpdated(_ notification: Notification) {
        
        DispatchQueue.main.async {
            self.requestsUpdated()
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
            self.tableView.reloadSections(IndexSet(integer: 0), with: .top)
        }

    }

    @objc func resetControllers(_ notification: Notification) {
        
        contactList.removeAll()
        contactRequests.removeAll()

    }
    
    @objc func addContact(_ item: Any) {

        if addContactView == nil {
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
                self.addContactView?.contactIdText.becomeFirstResponder()
            })
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

        return contactList.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
            as? ContactCell else { return UITableViewCell() }
        cell.setTheme()
        cell.configure(contact: contactList[indexPath.row])
        return cell

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 70.0

    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        return true

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        showContactDetailView(contact: contactList[indexPath.row])

    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let contactManager = ContactManager()
            let contact = contactList[indexPath.row]
            if let publicId = contact.publicId {
                // All contacts in the list should have public IDs
                contactManager.deleteContact(publicId: publicId)
            }
            else {
                DDLogError("Contact consistency error, public ID missing")
            }
        }
        
    }
 
}
