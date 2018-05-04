//
//  ChattoViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Chatto
import ChattoAdditions
import RKDropdownAlert
import ChameleonFramework

class ChattoViewController: BaseChatViewController, RKDropdownAlertDelegate {

    @objc var contact: Contact?
    var selectView: SelectContactView?
    var chatInputPresenter: BasicChatInputBarPresenter!
    var dataSource: ChattoDataSource!
    var messageManager = MessageManager()
    var suspended = false
    var authView: AuthViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.chatItemsDecorator = TextMessageDecorator()
        var items = [UIBarButtonItem]()
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editMessages(_:)))
        items.append(editItem)
        self.navigationItem.rightBarButtonItems = items

        NotificationCenter.default.addObserver(self, selector: #selector(contactSelected(_:)),
                                               name: Notifications.ContactSelected, object: nil)
        
        if let sboard = self.navigationController?.storyboard {
            authView =
                sboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController
            authView?.isAuthenticated = true
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if contact != nil {
            dataSource =
                ChattoDataSource(conversation: ConversationCache.getConversation(contact!.contactId))
            self.chatDataSource = dataSource
            self.navigationItem.title = contact!.displayName
        }
        else {
            let frame = self.view.bounds
            let viewRect = CGRect(x: 0.0, y: 0.0, width: frame.width * 0.8, height: frame.height * 0.7)
            selectView = SelectContactView(frame: viewRect)
            selectView!.contentView.backgroundColor = UIColor.init(gradientStyle: .topToBottom, withFrame: viewRect, andColors: [UIColor.flatPowderBlue, UIColor.flatSkyBlue])
            selectView!.contentView.alpha = 0.8
            selectView!.center = self.view.center
            self.view.addSubview(self.selectView!)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(appResumed(_:)),
                                               name: Notifications.AppResumed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appSuspended(_:)),
                                               name: Notifications.AppSuspended, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentAlert(_:)),
                                               name: Notifications.PresentAlert, object: nil)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: Notifications.PresentAlert, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.AppResumed, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.AppSuspended, object: nil)
        
    }
    
    override func createChatInputView() -> UIView {

        let chatInputView = ChatInputBar.loadNib()
        var appearance = ChatInputBarAppearance()
        appearance.sendButtonAppearance.title = NSLocalizedString("Send", comment: "")
        appearance.textInputAppearance.placeholderText = NSLocalizedString("Type a message", comment: "")
        appearance.textInputAppearance.font = UIFont.systemFont(ofSize: 14.0)
        self.chatInputPresenter = BasicChatInputBarPresenter(chatInputBar: chatInputView, chatInputItems: self.createChatInputItems(), chatInputBarAppearance: appearance)
        chatInputView.maxCharactersCount = 1000
        return chatInputView

    }

    func createChatInputItems() -> [ChatInputItemProtocol] {
        var items = [ChatInputItemProtocol]()
        items.append(self.createTextInputItem())
        // items.append(self.createPhotoInputItem())
        return items
    }
    
    private func createTextInputItem() -> TextChatInputItem {
        let item = TextChatInputItem()
        item.textInputHandler = { [weak self] text in
            let textMessage = TextMessage(text: text, contact: (self?.contact)!)
            let contactId = self?.contact?.contactId ?? 0
            do {
                let conversation = ConversationCache.getConversation(contactId)
                try conversation.sendMessage(textMessage)
                self?.dataSource.addTextMessage(textMessage)
            }
            catch {
                // TODO: Show alert
                print("\(error)")
            }
        }
        return item
    }
/*
    private func createPhotoInputItem() -> PhotosChatInputItem {
        let item = PhotosChatInputItem(presentingController: self)
        item.photoInputHandler = { [weak self] image in
            // Your handling logic
        }
        return item
    }
*/
    override func createPresenterBuilders() -> [ChatItemType : [ChatItemPresenterBuilderProtocol]] {

        let textMessagePresenter = TextMessagePresenterBuilder(
            viewModelBuilder: TextMessageViewModelDefaultBuilder<PippipTextMessageModel>(),
            interactionHandler: PippipTextMessageInteractionHandler())
        return [ "text-message-type": [textMessagePresenter] ]

    }

    @objc func cancelEdit(_ item: Any) {
        
        var items = [UIBarButtonItem]()
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editMessages(_:)))
        items.append(editItem)
        self.navigationItem.rightBarButtonItems = items
        
    }
    
    @objc func clearMessages(_ item: Any) {

        self.dataSource.clearMessages()
        
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
            if let info = notification.userInfo {
                authView?.suspendedTime = (info["suspendedTime"] as! NSNumber).intValue
            }
            DispatchQueue.main.async {
                self.present(self.authView!, animated: true, completion: nil)
            }
            
        }
        
    }
    
    @objc func appSuspended(_ notification: Notification) {
        
        suspended = true
        
    }
    
    @objc func contactSelected(_ notification: Notification) {
        
        contact = notification.object as? Contact
        dataSource =
            ChattoDataSource(conversation: ConversationCache.getConversation(contact!.contactId))
        DispatchQueue.main.async {
            self.chatDataSource = self.dataSource
            self.navigationItem.title = self.contact!.displayName
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
    
    func dropdownAlertWasTapped(_ alert: RKDropdownAlert!) -> Bool {
        return true
    }
    
    func dropdownAlertWasDismissed() -> Bool {
        return true
    }
    
}
