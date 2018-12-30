//
//  MessagesManager.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation
import RealmSwift

class MessagesModel: NSObject {

    private static var theInstance: MessagesModel?
    
    static var instance: MessagesModel {
        if let manager = theInstance {
            return manager
        }
        else {
            let newManager = MessagesModel()
            theInstance = newManager
            return newManager
        }
    }

    private override init() {
        super.init()
    }
    
    var config = Configurator()
    
    /*
     * Adds incoming messages to the database and to their conversations
     */
    func addTextMessages(_ textMessages: [TextMessage]) {
        
        let realm = try! Realm()
        for textMessage in textMessages {
            if getIdFromTuple(contactId: textMessage.contactId,
                              sequence: textMessage.sequence,
                              timestamp: textMessage.timestamp) == Int64(NSNotFound) {
                let dbMessage = textMessage.encodeForDatabase()
                dbMessage.messageId = config.newMessageId()
                textMessage.messageId = dbMessage.messageId
                try! realm.write {
                    realm.add(dbMessage)
                }
            }
            else {
                print("Duplicate message ID")
            }
        }
        
    }
    
    func getIdFromTuple(contactId: Int, sequence: Int64, timestamp: Int64) -> Int64 {
        
        let realm = try! Realm()
        let format = "contactId = %ld AND sequence = %lld AND timestamp = %lld"
        if let dbMessage = realm.objects(DatabaseMessage.self).filter(format, contactId, sequence, timestamp).first {
            return dbMessage.messageId
        }
        else {
            return Int64(NSNotFound)
            
        }
        
    }
    
}
