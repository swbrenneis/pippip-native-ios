//
//  ComposeViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/12/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {

    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    var contactList = [Contact]()
    var contactManager = ContactManager()
    var messageManager = MessageManager()
    var config = Configurator()
    var lastPartialLength = 0
    var decorator: MessagesContainerDecorator?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = PippipTheme.viewColor
        sendButton.setTitleColor(PippipTheme.buttonColor, for: .normal)
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchText.becomeFirstResponder()
        
    }
    
    func sendToDirectoryId(_ directoryId: String) {
        
        guard let messageText = messageTextField.text, messageText.count > 0 else { return }
        
        if let publicId = ContactsModel.instance.getPublicId(directoryId: directoryId) {
            sendtoPublicId(publicId)
        } else {
            contactManager.addContactRequest(publicId: nil, directoryId: directoryId, pendingMessage: messageText)
        }
        
    }
    
    func sendtoPublicId(_ publicId: String) {
        
        guard let messageText = messageTextField.text, messageText.count > 0 else { return }
        
        if let contact = ContactsModel.instance.getContact(publicId: publicId) {
            if let message = TextMessage(text: messageTextField.text!, contact: contact) {
                messageManager.sendMessage(textMessage: message, retry: false)
                let chatController = ChattoViewController()
                chatController.contact = contact
                self.show(chatController, sender: self)
            }
        } else {
            contactManager.addContactRequest(publicId: publicId, directoryId: nil, pendingMessage: messageText)
        }
        
    }

    @objc func contactRequested(_ notification: Notification) {
        
        NotificationCenter.default.removeObserver(self, name: Notifications.ContactRequested, object: nil)
        
        guard let contact = notification.object as? Contact else { return }
        let textMessage = TextMessage(text: messageTextField.text!, contact: contact)
        textMessage?.messageId = config.newMessageId()
        ConversationCache.instance.initialMessage(textMessage: textMessage!, contact: contact)
        DispatchQueue.main.async {
            let controller = ChattoViewController()
            controller.contact = contact
            self.show(controller, sender: self)
        }

    }
    
    @IBAction func searchChanged(_ sender: Any) {

//        selectButton.isEnabled = false
        let partial = searchText.text!
        let fragment = partial.uppercased()
        let newLength = partial.utf8.count
        
        var newList = [Contact]()
        if partial.utf8.count == 0 {
            contactList.removeAll()
        }
        else if newLength == 1 || newLength < lastPartialLength {
            newList.append(contentsOf: ContactsModel.instance.searchAcceptedContacts(fragment: fragment))
        }
        else {
            for contact in contactList {
                let publicId = contact.publicId.uppercased()
                if publicId.contains(fragment) {
                    newList.append(contact)
                }
                else if let directoryId = contact.directoryId?.uppercased() {
                    if directoryId.contains(fragment) {
                        newList.append(contact)
                    }
                }
            }
        }
        contactList.removeAll()
        for contact in newList {
            if contact.status == "accepted" {
                contactList.append(contact)
            }
        }
        lastPartialLength = newLength
        tableView.reloadSections(IndexSet(integer: 0), with: .none)
        
    }
    
    @IBAction func sendTapped(_ sender: Any) {

        if let name = searchText.text {
            let publicIdRegex = try! NSRegularExpression(pattern: "[a-fA-F0-9]{40}", options: .caseInsensitive)
            let matches = publicIdRegex.matches(in: name, options: [], range: NSRange(location: 0, length: name.count))
            if matches.count == 1 && name.count == 40 {
                sendtoPublicId(name)
            } else {
                sendToDirectoryId(name)
            }
            decorator?.viewMode = .preview
        }

    }

    @IBAction func messageTextSelected(_ sender: Any) {

        
    }

}

extension ComposeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let selectCell = tableView.dequeueReusableCell(withIdentifier: "SelectContactCell", for: indexPath)
        selectCell.textLabel?.text = contactList[indexPath.row].displayName
        return selectCell

    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        searchText.text = nil
        let chatController = ChattoViewController()
        chatController.contact = contactList[indexPath.row]
        contactList.removeAll()
        DispatchQueue.main.async {
            tableView.reloadSections(IndexSet(integer: 0), with: .none)
        }
        self.show(chatController, sender: self)

    }
    
}
