//
//  MessagesDatabase.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "MessagesDatabase.h"
#import "DatabaseMessage.h"
#import <Realm/Realm.h>

@interface MessagesDatabase ()
{

}

@property (weak, nonatomic) SessionState *sessionState;

@end

@implementation MessagesDatabase

- (instancetype)init {
    self = [super init];

    _conversations = [NSMutableDictionary dictionary];

    return self;

}

- (void)addMessage:(NSMutableDictionary*)message {

    NSString *publicId = message[@"publicId"];
    NSNumber *cid = message[@"contactId"];
    NSInteger contactId = [cid integerValue];
    NSMutableArray *conversation = _conversations[publicId];
    // No conversation in the map. Load it from the database.
    if (conversation == nil) {
        conversation = [self loadConversation:contactId];
    }
    // No conversation in the database. Create one.
    if (conversation == nil) {
        conversation = [NSMutableArray array];
        _conversations[publicId] = conversation;
    }
    
    if (conversation.count == 0) {
        [conversation addObject:message];
    }
    else {
        // Add the message in sorted order.
        NSUInteger index = [conversation indexOfObject:message
                                         inSortedRange:(NSRange){0, conversation.count}
                                               options:NSBinarySearchingInsertionIndex
                                       usingComparator:^(id obj1, id obj2) {
                                           NSDictionary *msg1 = obj1;
                                           NSNumber *ts1 = msg1[@"timestamp"];
                                           NSInteger time1 = [ts1 integerValue];
                                           NSDictionary *msg2 = obj2;
                                           NSNumber *ts2 = msg2[@"timestamp"];
                                           NSInteger time2 = [ts2 integerValue];
                                           if (time1 == time2) {
                                               // Hope not!
                                               NSLog(@"%@", @"Equal message timestamps!");
                                               return NSOrderedSame;
                                           }
                                           else if (time1 > time2) {
                                               return NSOrderedDescending;
                                           }
                                           else {
                                               return NSOrderedAscending;
                                           }
                                       }];
        [conversation insertObject:message atIndex:index];
    }
    
    // Add the message to the database
    DatabaseMessage *dbMessage = [[DatabaseMessage alloc] init];
    dbMessage.contactId = contactId;
    dbMessage.messageType = message[@"messageType"];
    NSNumber *ki = message[@"keyIndex"];
    dbMessage.keyIndex = [ki integerValue];
    NSNumber *sq = message[@"sequence"];
    dbMessage.sequence = [sq integerValue];
    NSNumber *ts = message[@"timestamp"];
    dbMessage.timestamp = [ts integerValue];
    dbMessage.read = @NO;
    NSNumber *ack = message[@"acknowledged"];
    dbMessage.acknowledged = [ack boolValue];

    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:dbMessage];
    [realm commitWriteTransaction];

}

- (NSArray*)mostRecent {

    NSMutableArray *recent = [NSMutableArray array];
    NSMutableDictionary *sample = [NSMutableDictionary dictionary];
    sample[@"read"] = @NO;
    sample[@"sender"] = @"Sally Joe";
    sample[@"message"] = @"The quick brown fox jumped over the lazy dog";
    sample[@"dateTime"] = @"Friday 14:53";
    [recent addObject:sample];

    return recent;

}

- (NSMutableArray*)loadConversation:(NSInteger)contactId {
    
    return nil;
    
}

- (BOOL)loadMessages:(SessionState*)state {

    _sessionState = state;
    return YES;
    
}

@end
