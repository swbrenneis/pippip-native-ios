//
//  DatabaseMessage.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/30/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Realm/Realm.h>

@interface DatabaseMessage : RLMObject

@property float version;
@property NSInteger contactId;
@property NSInteger messageId;
@property NSString *messageType;
@property NSData *message;
@property NSString *cleartext;
@property NSInteger keyIndex;
@property NSInteger sequence;
@property NSInteger timestamp;
@property BOOL read;
@property BOOL acknowledged;
@property BOOL sent;

@end
