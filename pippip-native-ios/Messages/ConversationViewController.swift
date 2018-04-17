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

        NotificationCenter.default.addObserver(self, selector: #selector(presentAlert(_:)),
                                               name: Notifications.PresentAlert, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)),
                                               name: .UIKeyboardWillShow, object: nil)

    }

    override func viewWillDisappear(_ animated: Bool) {

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
        let clearItem = UIBarButtonItem(title: "Clear", style: .plain,
                                        target: self, action: #selector(clearMessages(_:)))
        items.append(clearItem)
        self.navigationItem.rightBarButtonItems = items

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
