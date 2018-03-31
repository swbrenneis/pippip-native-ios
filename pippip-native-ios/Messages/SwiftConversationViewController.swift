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

class SwiftConversationViewController: BaseChatViewController {

    var messageSender: ConversationMessageSender!
    let messagesSelector = ConversationMessagesSelector()
    lazy private var conversationMessageHandler: ConversationMessageHandler = {
        return ConversationMessageHandler(messageSender: self.messageSender,
                                          messagesSelector: self.messagesSelector)
    }()
    var chatInputPresenter: BasicChatInputBarPresenter!
    var dataSource: ConversationDataSource! {
        didSet {
            self.chatDataSource = self.dataSource
            self.messageSender = self.dataSource.messageSender
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Someone"
        self.messagesSelector.delegate = self
        self.chatItemsDecorator = ConversationItemsDecorator(messagesSelector: self.messagesSelector)
        dataSource = ConversationDataSource(messages: ConversationMessageFactory.makeOverviewMessages(), pageSize: 50)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    override func createPresenterBuilders() -> [ChatItemType : [ChatItemPresenterBuilderProtocol]] {

        let textMessagePresenter = TextMessagePresenterBuilder(
            viewModelBuilder: ConversationViewModelBuilder(),
            interactionHandler: ConversationTextHandler(messageHandler: ConversationMessageHandler(messageSender: ConversationMessageSender(), messagesSelector: ConversationMessagesSelector())))
        return [ ConversationTextModel.chatItemType: [ textMessagePresenter ] ]

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
        // items.append(self.createPhotoInputItem()) Later!
        return items
    }
    
    private func createTextInputItem() -> TextChatInputItem {
        let item = TextChatInputItem()
        item.textInputHandler = { [weak self] text in
            self?.dataSource.addTextMessage(text)
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

extension SwiftConversationViewController: ConversationSelectorDelegate {
    func messagesSelector(_ messagesSelector: ConversationSelectorProtocol, didSelectMessage: MessageModelProtocol) {
        self.enqueueModelUpdate(updateType: .normal)
    }
    
    func messagesSelector(_ messagesSelector: ConversationSelectorProtocol, didDeselectMessage: MessageModelProtocol) {
        self.enqueueModelUpdate(updateType: .normal)
    }
}
