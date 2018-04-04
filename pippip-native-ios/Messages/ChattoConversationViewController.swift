//
//  SwiftConversationViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions
import PMAlertController
import RKDropdownAlert
import ChameleonFramework

class ChattoConversationViewController: BaseChatViewController {

    //var messageSender: ConversationMessageSender!
/*    let messagesSelector = ConversationMessagesSelector()
    lazy private var conversationMessageHandler: ConversationMessageHandler = {
        return ConversationMessageHandler(messageSender: self.messageSender,
                                          messagesSelector: self.messagesSelector)
    }() */
    var chatInputPresenter: BasicChatInputBarPresenter?
    var dataSource: TextDataSource? {
        didSet {
            self.chatDataSource = self.dataSource
            // self.messageSender = self.dataSource.messageSender
        }
    }

    @objc var publicId: String?
    var nickname: String?
    var contactManager = ContactManager()
    var contact: Contact?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contactManager.loadContactList()

        /*
        self.messagesSelector.delegate = self
        self.chatItemsDecorator = ConversationItemsDecorator(messagesSelector: self.messagesSelector)
        dataSource = ConversationDataSource(messages: ConversationMessageFactory.makeOverviewMessages(), pageSize: 50)
*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !loadContact() {
            let alert = PMAlertController(title: "Start A New Message",
                                          description: "Enter a nickname or public ID",
                                          image: nil,
                                          style: PMAlertControllerStyle.alert)
            alert.addTextField({ (textField) in
                textField?.placeholder = "Nickname"
                textField?.autocorrectionType = .no
                textField?.spellCheckingType = .no
            })
            alert.addTextField({ (textField) in
                textField?.placeholder = "Public ID"
                textField?.autocorrectionType = .no
                textField?.spellCheckingType = .no
            })
            alert.addAction(PMAlertAction(title: "Start Message",
                                          style: .default, action: { () in
                                            let nickname = alert.textFields[0].text ?? ""
                                            self.publicId = alert.textFields[1].text ?? ""
                                            if nickname.utf8.count > 0 {
                                                self.publicId = self.contactManager.getContactPublicId(nickname) ?? ""
                                            }
                                            if !self.loadContact() {
                                                let alertColor = UIColor.flatSand
                                                RKDropdownAlert.title("New Message Error", message: "That contact doesn't exist",
                                                                      backgroundColor: alertColor,
                                                                      textColor: ContrastColorOf(alertColor, returnFlat: true),
                                                                      time: 2, delegate: nil)
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                                    self.dismiss(animated: true, completion: nil)
                                                })
                                            }
            }))
            alert.addAction(PMAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true, completion: nil)
            return
        }

    }

    func loadContact() -> Bool {

        if publicId == "" {
            return false
        }

        contact = contactManager.getContact(publicId)
        if contact == nil {
            return false
        }

        if let nickname = contact?.nickname {
            self.title = nickname
        }
        return true

    }

    override func createPresenterBuilders() -> [ChatItemType : [ChatItemPresenterBuilderProtocol]] {

        let textMessagePresenter = TextPresenterBuilder()
        return [ TextMessageModel.chatItemType: [ textMessagePresenter ] ]

    }

    override func createChatInputView() -> UIView {

        let chatInputView = ChatInputBar.loadNib()
        var appearance = ChatInputBarAppearance()
        appearance.sendButtonAppearance.title = NSLocalizedString("Send", comment: "")
        // appearance.textInputAppearance.placeholderText = NSLocalizedString("Type a message", comment: "")
        self.chatInputPresenter = BasicChatInputBarPresenter(chatInputBar: chatInputView, chatInputItems: self.createChatInputItems(), chatInputBarAppearance: appearance)
        chatInputView.maxCharactersCount = 1000
        return chatInputView

    }

    func createChatInputItems() -> [ChatInputItemProtocol] {
        var items = [ChatInputItemProtocol]()
        items.append(self.createTextInputItem())
        // items.append(self.createPhotoInputItem()) Later!
        return items
    }

    private func createTextInputItem() -> TextChatInputItem {
        let item = TextChatInputItem()
        item.textInputHandler = { [weak self] text in
            self?.dataSource?.addTextMessage(text)
        }
        return item
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

extension ChattoConversationViewController: ConversationSelectorDelegate {
    func messagesSelector(_ messagesSelector: ConversationSelectorProtocol, didSelectMessage: MessageModelProtocol) {
        self.enqueueModelUpdate(updateType: .normal)
    }
    
    func messagesSelector(_ messagesSelector: ConversationSelectorProtocol, didDeselectMessage: MessageModelProtocol) {
        self.enqueueModelUpdate(updateType: .normal)
    }
}
