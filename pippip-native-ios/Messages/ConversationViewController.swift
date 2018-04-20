//
//  ConversationViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/4/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework
import RKDropdownAlert

class ConversationViewController: AsyncMessagesViewController, RKDropdownAlertDelegate {

    var conversationDataSource: ConversationDataSource?
    var conversationDelegate: ConversationCollectionDelegate
    var deferredDataSource: DeferredDataSource
    @objc var contact: Contact?
    var selectView: SelectContactView?
    var messageManager = MessageManager()
    var suspended = false
    var returnFromSuspend = false
    var authView: AuthViewController?

    init?() {

        conversationDelegate = ConversationCollectionDelegate()
        deferredDataSource = DeferredDataSource()
        
        super.init(dataSource: deferredDataSource,delegate: conversationDelegate)

    }
    
    required init(coder aDecoder: NSCoder) {

        conversationDelegate = ConversationCollectionDelegate()
        deferredDataSource = DeferredDataSource()

        super.init(coder: aDecoder)

    }

    override init?(tableViewStyle style: UITableViewStyle) {

        conversationDelegate = ConversationCollectionDelegate()
        deferredDataSource = DeferredDataSource()
        
        super.init(dataSource: deferredDataSource,delegate: conversationDelegate)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        authView =
            storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController
        
        NotificationCenter.default.addObserver(self, selector: #selector(contactSelected(_:)),
                                               name: Notifications.ContactSelected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(messageAdded(_:)),
                                               name: Notifications.MessageAdded, object: nil)

        var items = [UIBarButtonItem]()
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editMessages(_:)))
        items.append(editItem)
        self.navigationItem.rightBarButtonItems = items

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !returnFromSuspend {
            if contact == nil {
                let frame = self.view.bounds
                let viewRect = CGRect(x: 0.0, y: 0.0, width: frame.width * 0.8, height: frame.height * 0.7)
                selectView = SelectContactView(frame: viewRect)
                selectView!.contentView.backgroundColor = UIColor.init(gradientStyle: .topToBottom, withFrame: viewRect, andColors: [UIColor.flatPowderBlue, UIColor.flatSkyBlue])
                selectView!.contentView.alpha = 0.8
                selectView!.center = self.view.center
                self.view.addSubview(self.selectView!)
            }
            else {
                conversationDataSource = ConversationDataSource.init(collectionNode: asyncCollectionNode, contact: contact!)
                deferredDataSource.conversationDataSource = conversationDataSource!
                self.navigationItem.title = self.contact!.displayName
                self.contact!.conversation!.markMessagesRead()
                self.contact!.conversation!.isVisible = true
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(appResumed(_:)),
                                               name: Notifications.AppResumed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appSuspended(_:)),
                                               name: Notifications.AppSuspended, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentAlert(_:)),
                                               name: Notifications.PresentAlert, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)),
                                               name: .UIKeyboardWillShow, object: nil)

    }

    override func viewWillDisappear(_ animated: Bool) {

        NotificationCenter.default.removeObserver(self, name: Notifications.AppResumed, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.AppSuspended, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.PresentAlert, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        contact?.conversation!.isVisible = false

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func didPressRightButton(_ sender: Any?) {
    
        let text = textView.text
        let textMessage = TextMessage(text: text!, contact: contact!)
        textMessage.timestamp = contact!.conversation!.getTimestamp()
        conversationDataSource!.appendMessage(textMessage)

        DispatchQueue.global().async {
            do {
                try self.contact!.conversation!.sendMessage(textMessage)
            }
            catch {
                let alertColor = UIColor.flatSand
                RKDropdownAlert.title("Message Error", message: "Failed to send message", backgroundColor: alertColor,
                                      textColor: ContrastColorOf(alertColor, returnFlat: true),
                                      time: 2, delegate: self)
            }
        }

        super.didPressRightButton(sender)

    }

    @objc func cancelEdit(_ item: Any) {
        
        var items = [UIBarButtonItem]()
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editMessages(_:)))
        items.append(editItem)
        self.navigationItem.rightBarButtonItems = items
        
    }

    @objc func clearMessages(_ item: Any) {

        conversationDataSource!.clearMessages()
        contact!.conversation!.clearMessages()

        var items = [UIBarButtonItem]()
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editMessages(_:)))
        items.append(editItem)
        self.navigationItem.rightBarButtonItems = items
        
    }
    
    @objc func editMessages(_ item: Any) {

        var items = [UIBarButtonItem]()
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self,
                                         action: #selector(cancelEdit(_:)))
        items.append(cancelItem)
        let clearItem = UIBarButtonItem(title: "Clear", style: .plain,
                                        target: self, action: #selector(clearMessages(_:)))
        items.append(clearItem)
        self.navigationItem.rightBarButtonItems = items

    }

    @objc func appResumed(_ notification: Notification) {

        if suspended {
            suspended = false
            returnFromSuspend = true
            if let info = notification.userInfo {
                let suspendedTime = info["suspendedTime"] as! NSNumber
                if suspendedTime.intValue > 0 && suspendedTime.intValue < 180 {
                    authView!.suspended = true
                }
            }
            else {
                let auth = Authenticator()
                auth.logout()
            }
            DispatchQueue.main.async {
                self.present(self.authView!, animated: true, completion: nil)
                self.view.alpha = 1.0
            }

        }

    }
    
    @objc func appSuspended(_ notification: Notification) {

        suspended = true
        DispatchQueue.main.async {
            self.view.alpha = 0.2
        }

    }
    
    @objc func keyboardDidShow(_ notification: Notification) {

        self.scrollCollectionViewToBottom()

    }

    @objc func contactSelected(_ notification: Notification) {

        contact = notification.object as? Contact
        conversationDataSource = ConversationDataSource.init(collectionNode: asyncCollectionNode, contact: contact!)
        deferredDataSource.conversationDataSource = conversationDataSource!
        DispatchQueue.main.async {
            self.navigationItem.title = self.contact!.displayName
            self.contact!.conversation!.isVisible = true
        }

    }

    @objc func messageAdded(_ notification: Notification) {

        DispatchQueue.main.async {
            self.scrollCollectionViewToBottom()
        }

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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func dropdownAlertWasTapped(_ alert: RKDropdownAlert!) -> Bool {
        return true
    }
    
    func dropdownAlertWasDismissed() -> Bool {
        return true
    }
    
}
