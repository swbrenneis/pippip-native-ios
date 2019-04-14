//
//  MessagesViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework
import LocalAuthentication
import Sheriff
import MessageUI

class MessagesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageSearch: UISearchBar!
    
    var previews = [TextMessage]()
    var searched = [Conversation]()
    var sessionState = SessionState()
    var headingView: UIView!
    var wasReset = false
    var config = Configurator()
    var alertPresenter = AlertPresenter()
    var contactBarButton: UIBarButtonItem!
    var contactBadge = GIBadgeView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = PippipTheme.viewColor
        messageSearch.backgroundImage = UIImage()
        messageSearch.backgroundColor = PippipTheme.lightBarColor
        messageSearch.barTintColor = PippipTheme.navBarColor

        let headingFrame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 10)
        headingView = UIView(frame: headingFrame)
        headingView.backgroundColor = .clear

        // Do any additional setup after loading the view.
        /*
        var rightBarItems = [UIBarButtonItem]()
        let image = UIImage(named: "hamburgermenu")
        let hamburger = UIBarButtonItem(image: image, style: .plain, target: self,
                                        action: #selector(showSidebar(_:)))
        rightBarItems.append(hamburger)
        //let dbDump = UIBarButtonItem(title: "Dump", style: .plain, target: self, action: #selector(showMessageDump(_:)))
        //rightBarItems.append(dbDump)
        #if targetEnvironment(simulator)
        let pollButton = UIBarButtonItem(title: "Poll", style: .plain, target: self, action: #selector(pollServer(_ :)))
        rightBarItems.append(pollButton)
        #endif
        self.navigationItem.rightBarButtonItems = rightBarItems
        let composeImage = UIImage(named: "compose-small")?.withRenderingMode(.alwaysOriginal)
        let compose = UIBarButtonItem(image: composeImage, style: .plain,
                                      target: self, action: #selector(composeMessage(_:)))
        let contactImage = UIImage(named: "contacts-small")?.withRenderingMode(.alwaysOriginal)
        let contactImageView = UIImageView(image: contactImage)
        self.navigationItem.title = "Messages"

        contactBadge.topOffset = 3
        contactBarButton = UIBarButtonItem(customView: contactImageView)
        contactBarButton.customView?.addSubview(contactBadge)
        contactBarButton.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                                 action: #selector(showContacts(_:))))
*/
        tableView.delegate = self
        tableView.dataSource = self
        messageSearch.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(resetControllers(_:)),
                                               name: Notifications.ResetControllers, object: nil)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        alertPresenter.present = true

        if wasReset {
            wasReset = false
            tableView.reloadData()
        }
        
        /*
         *  ***** CAUTION! *****
         *
         * The app is not necessarily initialized when it gets here.
         *
         */
        if AccountSession.instance.serverAuthenticated {
            getMostRecentMessages()
            tableView.reloadData()
//            let p = ContactsModel.instance.pendingRequests.count
//            let s = config.statusUpdates
            contactBadge.badgeValue = ContactsModel.instance.pendingRequests.count
        }
        
        NotificationCenter.default.post(name: Notifications.SetNavBarTitle, object: "Message Previews")

        NotificationCenter.default.addObserver(self, selector: #selector(newMessages(_:)),
                                               name: Notifications.NewMessages, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(authComplete(_:)),
                                               name: Notifications.AuthComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setContactBadge(_:)),
                                               name: Notifications.SetContactBadge, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(conversationDeleted(_:)),
                                               name: Notifications.ConversationDeleted, object: nil)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        alertPresenter.present = false

        NotificationCenter.default.removeObserver(self, name: Notifications.NewMessages, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.AuthComplete, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.SetContactBadge, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.ConversationDeleted, object: nil)

    }
/*
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        authenticator.viewDidDisappear()
        
    }
*/
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getMostRecentMessages() {
        
        previews.removeAll()
        let contactList = ContactsModel.instance.acceptedContactList
        for contact in contactList {
            let conversation = MessagesModel.instance.getConversation(contactId: contact.contactId)
            if let message = conversation?.mostRecentMessage {
                previews.append(message)
            }
        }
        previews.sort(by: { (message1, message2) -> Bool in
            return message1.timestamp > message2.timestamp
        })
        
    }
    
    @objc func composeMessage(_ item: Any) {

        let chatto = ChattoViewController()
        self.navigationController?.pushViewController(chatto, animated: true)

    }

    #if targetEnvironment(simulator)
    @objc func pollServer(_ sender: Any) {
        AccountSession.instance.doUpdates()
    }
    #endif
/*
    @objc func showContacts(_ item: Any) {

        self.navigationController?.pushViewController(self.contactsView, animated: true)

    }
*/
    @objc func authComplete(_ notification: Notification) {
        
        guard let success = notification.object as? Bool else { return }
        if success {
            alertPresenter.present = true
            DispatchQueue.main.async {
                self.getMostRecentMessages()
                self.tableView.reloadData()
                self.contactBadge.badgeValue =  ContactsModel.instance.pendingRequests.count /* + self.config.statusUpdates */
            }
        }
        
    }
    
    @objc func conversationDeleted(_ notification: Notification) {
        
        guard let contactId = notification.object as? Int else { return }
        var path = IndexPath(row: -1, section: 0)
        for index in 0..<previews.count {
            if contactId == previews[index].contactId {
                path.row = index
            }
        }
        if path.row >= 0 {
            previews.remove(at: path.row)
            DispatchQueue.main.async {
                self.tableView.deleteRows(at: [path], with: .left)
            }
        }
    
    }
    
    @objc func newMessages(_ notification: Notification) {
        
        getMostRecentMessages()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    @objc func resetControllers(_ notification: Notification) {

        MessagesModel.instance.clearCache()
        previews.removeAll()
        wasReset = true

    }

    @objc func setContactBadge(_ notification: Notification) {

        DispatchQueue.main.async {
            self.contactBadge.badgeValue = ContactsModel.instance.pendingRequests.count /* + self.config.statusUpdates */
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

extension MessagesViewController: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        searched.removeAll()
        self.view.endEditing(true)
        getMostRecentMessages()
        messageSearch.text = nil
        self.tableView.reloadData()

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.utf8.count == 0 {
            searched.removeAll()
            getMostRecentMessages()
        }
        else if searchText.utf8.count == 1 {
            searchCache(searchText)
        }
        else {
            searchPreveiws(searchText)
        }
        self.tableView.reloadData()

    }

    func searchCache(_ fragment: String) {

        searched = MessagesModel.instance.searchConversations(fragment: fragment)
        previews.removeAll()
        for conversation in searched {
            previews.append(conversation.findMessageText(fragment)!)
        }

    }

    func searchPreveiws(_ fragment: String) {

        previews.removeAll()
        for conversation in searched {
            if let message = conversation.findMessageText(fragment) {
                previews.append(message)
            }
        }

    }

}

extension MessagesViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return previews.count;
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "PreviewCell",
                                                 for: indexPath) as! PreviewCell
        // Configure the cell...
        let message = previews[indexPath.item]
        // This is code necessary to allow for a bug that stores a message before the contact
        // has been accepted. It can be removed when general beta begins.
        if let contact = ContactsModel.instance.getContact(contactId: message.contactId) {
            if contact.status == "accepted" {
                cell.configure(textMessage: message)
            }
        }
        return cell;

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 75.0;

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.view.endEditing(true)
        let contactId = previews[indexPath.item].contactId
        let viewController = ChattoViewController()
        viewController.contact = ContactsModel.instance.getContact(contactId: contactId)
        self.navigationController?.pushViewController(viewController, animated: true)

    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let preview = previews[indexPath.row]
            MessagesModel.instance.deleteConversation(contactId: preview.contactId)
        }
        
    }
    
}
