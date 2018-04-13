//
//  DeferredDataSource.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/6/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class DeferredDataSource: NSObject, AsyncMessagesCollectionViewDataSource {

    var conversationDataSource: ConversationDataSource?

    func currentUserID() -> String? {
        guard let _ = conversationDataSource else { return "" }
        return conversationDataSource!.currentUserID()
    }
    
    func collectionNode(collectionNode: ASCollectionNode, updateCurrentUserID newUserID: String?) {
        guard let _ = conversationDataSource else { return }
        conversationDataSource!.collectionNode(collectionNode: collectionNode, updateCurrentUserID: newUserID)
    }
    
    func collectionNode(collectionNode: ASCollectionNode, messageForItemAtIndexPath indexPath: IndexPath) -> MessageData {
        guard let _ = conversationDataSource else { return ConversationMessageData() }
        return conversationDataSource!.collectionNode(collectionNode: collectionNode, messageForItemAtIndexPath: indexPath)
    }
    
    func collectionNode(collectionNode: ASCollectionNode, insertMessages newMessages: [MessageData], completion: ((Bool) -> ())?) {
        guard let _ = conversationDataSource else {
            completion?(true)
            return
        }
        conversationDataSource!.collectionNode(collectionNode: collectionNode, insertMessages: newMessages, completion: completion)
    }
    
    func collectionNode(collectionNode: ASCollectionNode, deleteMessagesAtIndexPaths indexPaths: [IndexPath],
                        completion: ((Bool) -> ())?) {
        guard let _ = conversationDataSource else {
            completion?(true)
            return
        }
        conversationDataSource!.collectionNode(collectionNode: collectionNode, deleteMessagesAtIndexPaths: indexPaths,
                                               completion: completion)
    }

    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        guard let _ = conversationDataSource else { return 0 }
        return conversationDataSource!.collectionNode(collectionNode, numberOfItemsInSection: section)
    }

    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard let _ = conversationDataSource else { return { return DeferredCellNode() } }
        return conversationDataSource!.collectionNode(collectionNode, nodeBlockForItemAt: indexPath)
    }

}

class DeferredCellNode: ASCellNode {

}

