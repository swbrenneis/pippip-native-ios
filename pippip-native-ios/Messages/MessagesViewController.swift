//
//  MessagesViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import FrostedSidebar
import ChameleonFramework
import LocalAuthentication
import Sheriff

class MessagesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageSearch: UISearchBar!
    
    var sidebar: FrostedSidebar!
    var sidebarOn = false
    var contactsView: ContactsViewController!
    var conversationVew: ChattoViewController!
    var settingsView: SettingsTableViewController!
    var previews = [TextMessage]()
    var searched = [Conversation]()
    var contactManager: ContactManager!
    var sessionState = SessionState()
    var headingView: UIView!
    var accountDeleted = false
    var config = Configurator()
    var authenticator = Authenticator()
    var localAuth: LocalAuthenticator!
    var alertPresenter = AlertPresenter()
    var contactBarButton: UIBarButtonItem!
    var contactBadge = GIBadgeView()
    var chatPushed = false

    override func viewDidLoad() {
        super.viewDidLoad()

        PippipTheme.setTheme()
        SecommAPI.initializeAPI()

        self.view.backgroundColor = PippipTheme.viewColor
        self.navigationController?.navigationBar.barTintColor = PippipTheme.navBarColor
        self.navigationController?.navigationBar.tintColor = PippipTheme.navBarTint
        messageSearch.backgroundColor = .clear
        messageSearch.barTintColor = PippipTheme.navBarColor
        let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.foregroundColor: PippipTheme.navBarTint]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes,
                                                                                                          for: .normal)

        let headingFrame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 10)
        headingView = UIView(frame: headingFrame)
        headingView.backgroundColor = .clear
        
        contactManager = ContactManager()
        localAuth = LocalAuthenticator(viewController: self, view: self.view)

        // Do any additional setup after loading the view.
        let sidebarImages = [ UIImage(named: "contacts")!, UIImage(named: "compose")!,
                              UIImage(named: "settings")!, UIImage(named: "exit")! ]
        sidebar = FrostedSidebar(itemImages: sidebarImages, colors: nil, selectionStyle: .single)
        contactsView = self.storyboard?.instantiateViewController(withIdentifier: "ContactsViewController") as! ContactsViewController
        settingsView = self.storyboard?.instantiateViewController(withIdentifier: "SettingsTableViewController") as! SettingsTableViewController
        sidebar.actionForIndex[0] = {
            self.sidebarOn = false
            self.sidebar.dismissAnimated(true, completion: nil)
            self.navigationController?.pushViewController(self.contactsView, animated: true)
        }
        sidebar.actionForIndex[1] = {
            self.sidebarOn = false
            self.sidebar.dismissAnimated(true, completion: nil)
            let chatto = ChattoViewController()
            self.navigationController?.pushViewController(chatto, animated: true)
        }
        sidebar.actionForIndex[2] = {
            self.sidebarOn = false
            self.sidebar.dismissAnimated(true, completion: nil)
            self.navigationController?.pushViewController(self.settingsView, animated: true)
        }
        sidebar.actionForIndex[3] = {
            self.sidebarOn = false
            self.sidebar.dismissAnimated(true, completion: nil)
            self.signOut()
        }

        var rightBarItems = [UIBarButtonItem]()
        let image = UIImage(named: "hamburgermenu")
        let hamburger = UIBarButtonItem(image: image, style: .plain, target: self,
                                        action: #selector(showSidebar(_:)))
        rightBarItems.append(hamburger)
        #if targetEnvironment(simulator)
        let pollButton = UIBarButtonItem(title: "Poll", style: .plain, target: self, action: #selector(pollServer(_ :)))
        rightBarItems.append(pollButton)
        #endif
        self.navigationItem.rightBarButtonItems = rightBarItems
        var leftBarItems = [UIBarButtonItem]()
        let composeImage = UIImage(named: "compose-small")?.withRenderingMode(.alwaysOriginal)
        let compose = UIBarButtonItem(image: composeImage, style: .plain,
                                      target: self, action: #selector(composeMessage(_:)))
        let contactImage = UIImage(named: "contacts-small")?.withRenderingMode(.alwaysOriginal)
        let contactImageView = UIImageView(image: contactImage)
        contactBarButton = UIBarButtonItem(customView: contactImageView)
        contactBarButton.customView?.addSubview(contactBadge)
        contactBarButton.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                                 action: #selector(showContacts(_:))))
        contactBadge.topOffset = 3
        leftBarItems.append(compose)
        leftBarItems.append(contactBarButton)
        self.navigationItem.leftBarButtonItems = leftBarItems

        tableView.delegate = self
        tableView.dataSource = self
        messageSearch.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(newSession(_:)),
                                               name: Notifications.NewSession, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(requestsUpdated(_:)),
                                               name: Notifications.RequestsUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(requestAcknowledged(_:)),
                                               name: Notifications.RequestAcknowledged, object: nil)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        alertPresenter.present = true
        if chatPushed {
            chatPushed = false
        }
        else {
            localAuth.listening = true
        }

        NotificationCenter.default.addObserver(self, selector: #selector(newMessages(_:)),
                                               name: Notifications.NewMessages, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(thumbprintComplete(_:)),
                                               name: Notifications.ThumbprintComplete, object: nil)

        if accountDeleted {
            previews.removeAll()
            tableView.reloadData()
            accountDeleted = false
            localAuth.visible = true
        }
        else if sessionState.authenticated {
            getMostRecentMessages()
            tableView.reloadData()
            let requests = contactManager.pendingRequests
            contactBadge.badgeValue = requests.count
        }
        else {
            localAuth.visible = true
        }

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        alertPresenter.present = false
        if !chatPushed {
            localAuth.listening = false
        }
        NotificationCenter.default.removeObserver(self, name: Notifications.NewMessages, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.ThumbprintComplete, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func composeMessage(_ item: Any) {

        let chatto = ChattoViewController()
        self.navigationController?.pushViewController(chatto, animated: true)

    }

    #if targetEnvironment(simulator)
    @objc func pollServer(_ sender: Any) {
        ApplicationInitializer.accountSession.doUpdates()
    }
    #endif

    @objc func showContacts(_ item: Any) {

        self.navigationController?.pushViewController(self.contactsView, animated: true)

    }

    @objc func showSidebar(_ item: Any) {

        self.view.endEditing(true)
        if sidebarOn {
            sidebarOn = false
            sidebar.dismissAnimated(true, completion: nil)
        }
        else {
            sidebarOn = true
            sidebar.showInViewController(self, animated: true)
        }

    }

    func getMostRecentMessages() {

        previews.removeAll()
        let contactList = contactManager.contactList
        for contact in contactList {
            let conversation = ConversationCache.getConversation(contact.contactId)
            if let message = conversation.mostRecentMessage() {
                previews.append(message)
            }
        }
        
    }

    func signOut() {
        
        previews.removeAll()
        let auth = Authenticator()
        auth.logout()

    }

    // Notifications
    
    @objc func newMessages(_ notification: Notification) {

        if !chatPushed {
            getMostRecentMessages()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    @objc func newSession(_ notification: Notification) {

        let accountManager = AccountManager()
        accountManager.loadConfig()
        getMostRecentMessages()
        let requests = contactManager.pendingRequests
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.localAuth.visible = false
            self.contactBadge.badgeValue = requests.count
        }

    }

    @objc func requestsUpdated(_ notification: Notification) {

        let requests = contactManager.pendingRequests
        DispatchQueue.main.async {
            let badgeCount = requests.count
            self.contactBadge.badgeValue = badgeCount
        }
        
    }
    
    @objc func requestAcknowledged(_ notification: Notification) {
        
        DispatchQueue.main.async {
            var badgeCount = self.contactBadge.badgeValue - 1
            if (badgeCount < 0) {
                badgeCount = 0
            }
            self.contactBadge.badgeValue = badgeCount
        }
        
    }
    
    @objc func thumbprintComplete(_ notification: Notification) {

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

        searched = ConversationCache.searchConversations(fragment)
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
        if let contact = contactManager.getContact(contactId: message.contactId) {
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
        viewController.contact = contactManager.getContact(contactId: contactId)
        chatPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)

    }

}
