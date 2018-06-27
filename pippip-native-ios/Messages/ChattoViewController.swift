//
//  ChattoViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Chatto
import ChattoAdditions
import ChameleonFramework
import AudioToolbox

class ChattoViewController: BaseChatViewController {

    static var receiveSoundId: SystemSoundID = 0

    var contact: Contact?
    var selectView: SelectContactView?
    var chatInputPresenter: BasicChatInputBarPresenter!
    var dataSource: ChattoDataSource?
    var messageManager = MessageManager()
    var alertPresenter = AlertPresenter()
    var localAuth: LocalAuthenticator?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = PippipTheme.viewColor
        self.collectionView.backgroundColor = .clear

        self.chatItemsDecorator = TextMessageDecorator()
        var items = [UIBarButtonItem]()
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editMessages(_:)))
        items.append(editItem)
        #if targetEnvironment(simulator)
        let pollButton = UIBarButtonItem(title: "Poll", style: .plain, target: self, action: #selector(pollServer(_ :)))
        items.append(pollButton)
        #endif
        self.navigationItem.rightBarButtonItems = items

        if ChattoViewController.receiveSoundId == 0 {
            if let receiveUrl = Bundle.main.url(forResource: "iphone_receive_sms", withExtension: "mp3") {
                AudioServicesCreateSystemSoundID(receiveUrl as CFURL, &ChattoViewController.receiveSoundId)
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(contactSelected(_:)),
                                               name: Notifications.ContactSelected, object: nil)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        alertPresenter.present = true
        if localAuth == nil {
            localAuth = LocalAuthenticator(viewController: self, view: self.view)
        }
        localAuth?.listening = true
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
        dataSource?.visible = true

        NotificationCenter.default.addObserver(self, selector: #selector(appSuspended(_:)),
                                               name: Notifications.AppSuspended, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(retryMessage(_:)),
                                               name: Notifications.RetryMessage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(localAuthComplete(_:)),
                                               name: Notifications.LocalAuthComplete, object: nil)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        alertPresenter.present = false
        localAuth?.listening = false
        dataSource?.visible = false

        NotificationCenter.default.removeObserver(self, name: Notifications.AppSuspended, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.RetryMessage, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.LocalAuthComplete, object: nil)

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
            if let textMessage = TextMessage(text: text, contact: (self?.contact)!) {
                do {
                    textMessage.read = true
                    try textMessage.encrypt()
                    textMessage.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
                    self?.messageManager.sendMessage(textMessage: textMessage, retry: false)
                    self?.dataSource?.addTextMessage(textMessage)
                }
                catch {
                    // TODO: Show alert
                    print("\(error)")
                }
            }
            // TODO: report error
        }
        return item
    }

    override func createPresenterBuilders() -> [ChatItemType : [ChatItemPresenterBuilderProtocol]] {

        let textMessagePresenter = TextMessagePresenterBuilder(
            viewModelBuilder: TextMessageViewModelDefaultBuilder<PippipTextMessageModel>(),
            interactionHandler: PippipTextMessageInteractionHandler())
        return [ "text-message-type": [textMessagePresenter] ]

    }

    // Notifications
    
    @objc func appSuspended(_ notification: Notification) {
        
/*        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        } */
        
    }
    
    @objc func contactSelected(_ notification: Notification) {
        
        contact = notification.object as? Contact
        dataSource =
            ChattoDataSource(conversation: ConversationCache.getConversation(contact!.contactId))
        dataSource?.visible = true
        DispatchQueue.main.async {
            self.chatDataSource = self.dataSource
            self.navigationItem.title = self.contact!.displayName
        }
        
    }
    
    @objc func retryMessage(_ notification: Notification) {

        guard let textMessage = notification.object as? TextMessage else { return }
        dataSource?.retryTextMessage(textMessage)

    }

    @objc func localAuthComplete(_ notification: Notification) {
        
        DispatchQueue.main.async {
            self.localAuth?.visible = false
        }
        
    }
    
    // UI actions
    @objc func cancelEdit(_ item: Any) {
        
        var items = [UIBarButtonItem]()
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editMessages(_:)))
        items.append(editItem)
        self.navigationItem.rightBarButtonItems = items
        
    }
    
    @objc func clearMessages(_ item: Any) {

        self.dataSource?.clearMessages()
        
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

    #if targetEnvironment(simulator)
    @objc func pollServer(_ sender: Any) {
        ApplicationInitializer.accountSession.doUpdates()
    }
    #endif
    
}
