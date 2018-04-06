//
//  ConversationViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/4/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework

class ConversationViewController: AsyncMessagesViewController {

    var conversationDataSource: ConversationDataSource?
    var conversationDelegate: ConversationCollectionDelegate
    var deferredDataSource: DeferredDataSource
    var contact: Contact?
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
        NotificationCenter.default.addObserver(self, selector: #selector(messagesLoaded(_:)),
                                               name: Notifications.MessagesLoaded, object: nil)

        
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
            conversationDataSource!.loadMessages()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func didPressRightButton(_ sender: Any?) {
    
        let text = textView.text
        let textMessage = TextMessage(text: text!, contact: contact!)
        messageManager.sendMessage(textMessage, retry: false)

        super.didPressRightButton(sender)

    }

    @objc func contactSelected(_ notification: Notification) {

        contact = notification.object as? Contact
        conversationDataSource = ConversationDataSource.init(collectionNode: asyncCollectionNode, contact: contact!)
        deferredDataSource.conversationDataSource = conversationDataSource!
        conversationDataSource!.loadMessages()
        DispatchQueue.main.async {
            if let nickname = self.contact?.nickname {
                self.navigationItem.title = nickname
            }
            else {
                let fragment = String(describing: self.contact!.publicId.prefix(10)) + "..."
                self.navigationItem.title = fragment
            }
        }

    }

    @objc func messageSent(_ notification: Notification) {

        if let message = notification.object as? TextMessage {
            conversationDataSource!.appendMessage(message)
        }

    }

    @objc func messagesLoaded(_ notification: Notification) {

        DispatchQueue.main.async {
            self.scrollCollectionViewToBottom()
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
