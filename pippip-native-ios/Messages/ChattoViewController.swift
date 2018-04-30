//
//  ChattoViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Chatto
import ChattoAdditions

class ChattoViewController: BaseChatViewController {

    @objc var contact: Contact!
    var chatInputPresenter: BasicChatInputBarPresenter!
    var dataSource: ChattoDataSource!
    var messageManager = MessageManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource =
            ChattoDataSource(conversation: ConversationCache.getConversation(contact!.contactId))
        self.chatDataSource = dataSource
        self.chatItemsDecorator = TextMessageDecorator()
        self.navigationItem.title = contact.displayName

    }

    override func createChatInputView() -> UIView {
        let chatInputView = ChatInputBar.loadNib()
        var appearance = ChatInputBarAppearance()
        appearance.sendButtonAppearance.title = NSLocalizedString("Send", comment: "")
        appearance.textInputAppearance.placeholderText = NSLocalizedString("Type a message", comment: "")
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
            do {
                try self?.messageManager.sendMessage(textMessage, retry: false)
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
            viewModelBuilder: PippipTextMessageViewModelBuilder(),
            interactionHandler: PippipTextMessageInteractionHandler())
        return [ "text-message-type": [textMessagePresenter] ]

    }

}
