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
import MessageUI
import ImageSlideshow

class MessagesViewController: UIViewController, AuthenticationDelegateProtocol {

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
    var slideshow: ImageSlideshow!
    let slides = [ImageSource(imageString: "quickstart01")!,
                  ImageSource(imageString: "quickstart02")!,
                  ImageSource(imageString: "quickstart03")!,
                  ImageSource(imageString: "quickstart04")!,
                  ImageSource(imageString: "quickstart05")!,
                  ImageSource(imageString: "quickstart06")!,
                  ImageSource(imageString: "quickstart07")!,
                  ImageSource(imageString: "quickstart08")!,
                  ImageSource(imageString: "quickstart09")!,
                  ImageSource(imageString: "quickstart10")!,
                  ImageSource(imageString: "quickstart11")!,
                  ImageSource(imageString: "quickstart12")!,
                  ImageSource(imageString: "quickstart13")!]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = PippipTheme.viewColor
        self.navigationController?.navigationBar.barTintColor = PippipTheme.navBarColor
        self.navigationController?.navigationBar.tintColor = PippipTheme.navBarTint
        messageSearch.backgroundImage = UIImage()
        messageSearch.backgroundColor = PippipTheme.lightBarColor
        messageSearch.barTintColor = PippipTheme.navBarColor
        //messageSearch.alpha = 0.4
        //let cancelButton = UIButton.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        //cancelButton.setTitleColor(PippipTheme.navBarColor.darken(byPercentage: 0.2), for: .normal)
//        let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.foregroundColor: PippipTheme.navBarColor]
//        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes,
//                                                                                                          for: .normal)

        let headingFrame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 10)
        headingView = UIView(frame: headingFrame)
        headingView.backgroundColor = .clear
        
        contactManager = ContactManager()
        localAuth = LocalAuthenticator(viewController: self, view: self.view)
        authenticator.delegate = self

        let bounds = self.view.bounds
        slideshow = ImageSlideshow(frame: bounds)
        slideshow.setImageInputs(slides)
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(MessagesViewController.didTap))
        slideshow.addGestureRecognizer(recognizer)
        slideshow.alpha = 0.0
        self.view.addSubview(slideshow)
        
        // Do any additional setup after loading the view.
//        let sidebarImages = [ UIImage(named: "help")!, UIImage(named: "contacts")!,
//                              UIImage(named: "compose")!, UIImage(named: "settings")!,
//                              UIImage(named: "exit")! ]
        let sidebarImages = [ UIImage(named: "help")!, UIImage(named: "settings")!,
                              UIImage(named: "exit")! ]
        sidebar = FrostedSidebar(itemImages: sidebarImages, colors: nil, selectionStyle: .single)
        sidebar.showFromRight = true
        sidebar.itemBackgroundColor = .clear
        sidebar.adjustForNavigationBar = true
        sidebar.itemSize = CGSize(width: 130.0, height: 130.0)
        contactsView = (self.storyboard?.instantiateViewController(withIdentifier: "ContactsViewController") as! ContactsViewController)
        settingsView = (self.storyboard?.instantiateViewController(withIdentifier: "SettingsTableViewController") as! SettingsTableViewController)
        sidebar.actionForIndex[0] = {
            self.sidebarOn = false
            self.sidebar.dismissAnimated(true, completion: nil)
            UIView.animate(withDuration: 0.3, animations: {
                self.slideshow.alpha = 1.0
            }, completion: { (completed) in
                self.navigationController?.setNavigationBarHidden(true, animated: true)
            })
        }
        sidebar.actionForIndex[1] = {
            self.sidebarOn = false
            self.sidebar.dismissAnimated(true, completion: nil)
            self.navigationController?.pushViewController(self.settingsView, animated: true)
        }
        sidebar.actionForIndex[2] = {
            self.sidebarOn = false
            self.sidebar.dismissAnimated(true, completion: nil)
            self.signOut()
        }

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
        var leftBarItems = [UIBarButtonItem]()
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
        leftBarItems.append(compose)
        leftBarItems.append(contactBarButton)
        self.navigationItem.leftBarButtonItems = leftBarItems

        tableView.delegate = self
        tableView.dataSource = self
        messageSearch.delegate = self

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        alertPresenter.present = true
        localAuth.listening = true

        NotificationCenter.default.addObserver(self, selector: #selector(newMessages(_:)),
                                               name: Notifications.NewMessages, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(localAuthComplete(_:)),
                                               name: Notifications.LocalAuthComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setContactBadge(_:)),
                                               name: Notifications.SetContactBadge, object: nil)

        getMostRecentMessages()
        tableView.reloadData()
        contactBadge.badgeValue =  contactManager.pendingRequests.count + config.statusUpdates

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let bounds = self.navigationController!.navigationBar.bounds
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0,
                                                                width: bounds.width,
                                                                height: bounds.height + 6.0)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        alertPresenter.present = false
        localAuth.listening = false

        NotificationCenter.default.removeObserver(self, name: Notifications.NewMessages, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.LocalAuthComplete, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func composeMessage(_ item: Any) {

        let chatto = ChattoViewController()
        self.navigationController?.pushViewController(chatto, animated: true)

    }

    @objc func didTap() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.slideshow.alpha = 0.0
        }, completion: { (completed) in
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        })

    }
    
    #if targetEnvironment(simulator)
    @objc func pollServer(_ sender: Any) {
        ApplicationInitializer.accountSession.doUpdates()
    }
    #endif

    @objc func showContacts(_ item: Any) {

        self.navigationController?.pushViewController(self.contactsView, animated: true)

    }

    @objc func showMessageDump(_ item: Any) {
        
        let dumpView = self.storyboard?.instantiateViewController(withIdentifier: "MessageDumpTableViewController")
            as! MessageDumpTableViewController
        self.navigationController?.pushViewController(dumpView, animated: true)

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
            if let message = conversation.mostRecentMessage {
                previews.append(message)
            }
        }
        previews.sort(by: { (message1, message2) -> Bool in
            return message1.timestamp > message2.timestamp
        })

    }

    func signOut() {
        
        previews.removeAll()
        authenticator.logout()

    }

    // Notifications
    
    @objc func setContactBadge(_ notification: Notification) {

        DispatchQueue.main.async {
            self.contactBadge.badgeValue = self.contactManager.pendingRequests.count + self.config.statusUpdates
        }

    }
    
    @objc func newMessages(_ notification: Notification) {

        getMostRecentMessages()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }

    @objc func localAuthComplete(_ notification: Notification) {

        DispatchQueue.main.async {
            self.localAuth.showAuthView = false
        }

    }

    // Authentication delegate
    
    func authenticated() {
        // Nothing to do
    }
    
    func authenticationFailed(reason: String) {
        // Nothing to do
    }

    func loggedOut() {

        AsyncNotifier.notify(name: Notifications.SessionEnded)
        DispatchQueue.main.async {
            self.navigationController?.performSegue(withIdentifier: "AuthViewSegue", sender: nil)
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
        self.navigationController?.pushViewController(viewController, animated: true)

    }

}
