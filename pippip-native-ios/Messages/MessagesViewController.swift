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
import RKDropdownAlert

class MessagesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var sidebar: FrostedSidebar!
    var sidebarOn = false
    var contactsView: ContactsViewController!
    var conversationVew: ChattoViewController!
    var settingsView: MoreTableViewController!
    var mostRecent = [TextMessage]()
    //var colorScheme = ColorSchemeOf(.complementary, color: UIColor.flatForestGreen, isFlatScheme: true)
    var contactManager: ContactManager!
    var sessionState = SessionState()
    var authView: AuthViewController!
    var headingView: UIView!
    var suspended = false
    var accountDeleted = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.flatForestGreen
        let headingFrame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 10)
        headingView = UIView(frame: headingFrame)
        headingView.backgroundColor = .clear

        // Do any additional setup after loading the view.
        let sidebarImages = [ UIImage(named: "contacts")!, UIImage(named: "compose")!,
                              UIImage(named: "settings")!, UIImage(named: "exit")! ]
        sidebar = FrostedSidebar(itemImages: sidebarImages, colors: nil, selectionStyle: .single)
        contactsView = self.storyboard?.instantiateViewController(withIdentifier: "ContactsViewController") as! ContactsViewController
        settingsView = self.storyboard?.instantiateViewController(withIdentifier: "MoreTableViewController") as! MoreTableViewController
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

        var items = [UIBarButtonItem]()
        let image = UIImage(named: "hamburgermenu")
        let hamburger = UIBarButtonItem(image: image, style: .plain, target: self,
                                        action: #selector(showSidebar(_:)))
        items.append(hamburger)
        self.navigationItem.rightBarButtonItems = items
        /*
        let titleView = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        titleView.image = UIImage(named: "pippip3")
        self.navigationItem.titleView = titleView
 */
        //self.navigationItem.title = "Pippip Messaging"

        tableView.delegate = self
        tableView.dataSource = self

        authView =
            self.storyboard?.instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController

        NotificationCenter.default.addObserver(self, selector: #selector(appResumed(_:)),
                                               name: Notifications.AppResumed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appSuspended(_:)),
                                               name: Notifications.AppSuspended, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newSession(_:)),
                                               name: Notifications.NewSession, object: nil)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(newMessages(_:)),
                                               name: Notifications.NewMessages, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentAlert(_:)),
                                               name: Notifications.PresentAlert, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(thumbprintComplete(_:)),
                                               name: Notifications.ThumbprintComplete, object: nil)

        if sessionState.authenticated && !suspended {
            getMostRecentMessages()
            tableView.reloadData()
        }

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: Notifications.NewMessages, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.PresentAlert, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.ThumbprintComplete, object: nil)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if accountDeleted {
            mostRecent.removeAll()
            self.present(authView, animated: true, completion: nil)
            accountDeleted = false
        }
        else if !sessionState.authenticated {
            self.present(authView, animated: true, completion: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func showSidebar(_ item: Any) {

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

        mostRecent.removeAll()
        let contactList = contactManager.getContactList()
        for contact in contactList {
            let conversation = ConversationCache.getConversation(contact.contactId)
            if let message = conversation.mostRecentMessage() {
                mostRecent.append(message)
            }
        }
        
    }

    @objc func appResumed(_ notification: Notification) {

        if suspended && sessionState.authenticated {
            suspended = false
            let info = notification.userInfo!
            authView.suspendedTime = info["suspendedTime"] as? Int ?? 0
            DispatchQueue.main.async {
                self.present(self.authView, animated: true, completion: nil)
            }
        }
        
    }
    
    func signOut() {
        
        mostRecent.removeAll()
        let auth = Authenticator()
        auth.logout()
        authView.isAuthenticated = false
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.present(self.authView, animated: true, completion: nil)
        }

    }
    
    @objc func appSuspended(_ notification: Notification) {

        suspended = true
        mostRecent.removeAll()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }

    @objc func newSession(_ notification: Notification) {

        authView.isAuthenticated = true
        contactManager = ContactManager()
        getMostRecentMessages()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

    }
    
    @objc func newMessages(_ notification: Notification) {

        getMostRecentMessages()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    @objc func presentAlert(_ notification: Notification) {

        let info = notification.userInfo!
        let title = info["title"] as! String
        let message = info["message"] as! String
        DispatchQueue.main.async {
            let alertColor = UIColor.flatSand
            RKDropdownAlert.title(title, message: message, backgroundColor: alertColor,
                                  textColor: ContrastColorOf(alertColor, returnFlat: true),
                                  delegate: nil)
        }
        
    }
    
    @objc func thumbprintComplete(_ notification: Notification) {

        getMostRecentMessages()
        DispatchQueue.main.async {
            self.tableView.reloadData()
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

extension MessagesViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            return 1;
        }
        else {
            return mostRecent.count;
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessagesHeadingCell",
                                                     for: indexPath) as! MessagesHeadingCell
            cell.configure(backgroundColor: UIColor.flatCoffee)
            cell.messageSearchTextField.delegate = self
            return cell;
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PreviewCell",
                                                     for: indexPath) as! PreviewCell
            // Configure the cell...
            let message = mostRecent[indexPath.item]
            // This is code necessary to allow for a bug that stores a message before the contact
            // has been accepted. It can be removed when general beta begins.
            if let contact = contactManager.getContactById(message.contactId) {
                if contact.status == "accepted" {
                    cell.configure(textMessage: message, backgroundColor: UIColor.flatCoffeeDark)
                }
            }
            return cell;
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if (indexPath.section == 0) {
            return 112.0;
        }
        else {
            return 75.0;
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if (indexPath.section == 1) {
            let contactId = mostRecent[indexPath.item].contactId
            let viewController = ChattoViewController()
            viewController.contact = contactManager.getContactById(contactId)
            self.navigationController?.pushViewController(viewController, animated: true)
        }

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 1 {
            return 5
        }
        else {
            return 0
        }

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if section == 1 {
            return headingView
        }
        else {
            return nil
        }

    }
}

extension MessagesViewController: UITextFieldDelegate {
    
}
