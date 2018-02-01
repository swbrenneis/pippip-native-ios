//
//  Message.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/30/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Realm/Realm.h>

@interface Message : RLMObject

@property NSString *fromId;
@property NSString *messageType;
@property NSData *message;
@property NSInteger keyIndex;
@property NSInteger sequence;
@property NSInteger timestamp;
@property BOOL acknowledged;

@end
