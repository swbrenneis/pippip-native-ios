//
//  ConversationDelegate.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/22/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ConversationDelegate.h"
#import "MessagesDatabase.h"
//#import "CKSHA1.h"

@interface ConversationDelegate ()
{
    // Dictionary of message ID to message
    NSMutableDictionary *conversation;
    MessagesDatabase *messageDatabase;
}

@end

@implementation ConversationDelegate

- (instancetype)initWithPublicId:(NSString*)publicId {
    self = [super init];

    _publicId = publicId;
    conversation = [NSMutableDictionary dictionary];
    messageDatabase = [[MessagesDatabase alloc] init];

    return self;

}
/*
- (instancetype)initWithMessageIds:(NSArray*)messages {
    self = [super init];
    
    conversation = [NSMutableDictionary dictionary];
    for (NSMutableDictionary *message in messages) {
        conversation[message[@"messageId"]] = message;
    }
    _count = conversation.count;
    
    return self;
    
}
*/
- (void)acknowledgeMessage:(NSInteger)messageId {
    
    NSMutableDictionary *message = conversation[[NSNumber numberWithInteger:messageId]];
    message[@"acknowledged"] = @YES;
    
}

- (void)addMessage:(NSMutableDictionary*)message {

    NSDictionary *exists = conversation[message[@"messageId"]];
    if (exists == nil) {
        conversation[message[@"messageId"]] = message;
    }
    _count = conversation.count;
    
}

- (void)addMessageIdSorted:(NSNumber*)messageId withIdList:(NSMutableArray*)idList{

    if (idList.count == 0) {
        [idList addObject:messageId];
    }
    else {
        // Add the message in sorted order.
        NSUInteger index = [idList indexOfObject:messageId
                                   inSortedRange:(NSRange){0, idList.count}
                                         options:NSBinarySearchingInsertionIndex
                                 usingComparator:^(id obj1, id obj2) {
                                     NSNumber *num1 = obj1;
                                     NSNumber *num2 = obj2;
                                     NSInteger id1 = [num1 integerValue];
                                     NSInteger id2 = [num2 integerValue];
                                     if (id1 == id2) {
                                         // Hope not!
                                         NSLog(@"%@", @"Equal message timestamps!");
                                         return NSOrderedSame;
                                     }
                                     else if (id1 > id2) {
                                         return NSOrderedDescending;
                                     }
                                     else {
                                         return NSOrderedAscending;
                                     }
                                 }];
        [idList insertObject:messageId atIndex:index];
    }
    
}

- (NSArray*)allMessageIds {

    NSArray *ids = [messageDatabase loadMessageIds:_publicId];
    if (ids.count < conversation.count) {
        for (NSNumber *mid in ids) {
            if (conversation[mid] == nil) {
                conversation[mid] = [NSMutableDictionary dictionary];
            }
        }
    }
    _count = ids.count;
    return ids;
    
}

- (void)deleteAllMessages {

    [conversation removeAllObjects];
    _count = 0;

}

- (void)deleteMessage:(NSInteger)messageId {

    [conversation removeObjectForKey:[NSNumber numberWithInteger:messageId]];
    _count = conversation.count;

}

- (NSMutableDictionary*)getMessage:(NSInteger)messageId {

    NSMutableDictionary *message = conversation[[NSNumber numberWithInteger:messageId]];
    if (message == nil || message[@"messageId"] == nil) {
        message = [messageDatabase loadMessage:messageId withPublicId:_publicId];
        conversation[message[@"messageId"]] = message;
    }
    return message;
    
}
/*
- (NSString*)getMessageHash:(NSDictionary*)triplet {
    
    NSString *publicId = triplet[@"publicId"];
    NSNumber *sq = triplet[@"sequence"];
    NSInteger sequence = [sq integerValue];
    NSNumber *ts = triplet[@"timestamp"];
    NSInteger timestamp = [ts integerValue];
    
    CKSHA1 *sha1 = [[CKSHA1 alloc] init];
    [sha1 update:[publicId dataUsingEncoding:NSUTF8StringEncoding]];
    [sha1 update:[NSData dataWithBytes:&sequence length:sizeof(NSInteger)]];
    [sha1 update:[NSData dataWithBytes:&timestamp length:sizeof(NSInteger)]];
    return [[sha1 digest] base64EncodedStringWithOptions:0];
    
}
*/
- (void)markMessageRead:(NSInteger)messageId {
    
    NSMutableDictionary *message = conversation[[NSNumber numberWithInteger:messageId]];
    message[@"read"] = @YES;
    
}
/*
- (NSInteger)messageExists:(NSDictionary *)triplet {
    
    NSString *hash = [self getMessageHash:triplet];
    NSDictionary *message = conversation[hash];
    if (message != nil) {
        return [message[@"messageId"] integerValue];
    }
    else {
        return NSNotFound;
    }
    
}

- (NSArray*)pendingMessages {
    
    if (messageList.count == 0) {
        [self sortMessages];
    }
    NSMutableArray *pending = [NSMutableArray array];
    for (NSDictionary *message in messageList) {
        NSNumber *ack = message[@"acknowledged"];
        if (![ack boolValue]) {
            [pending addObject:message];
        }
    }
    return pending;
    
}

- (void)sortMessages {
    
    [messageList removeAllObjects];
    if (conversation.count > 0) {
        for (NSString *hash in conversation) {
            [self addMessageSorted:conversation[hash]];
        }
    }
    
}
*/
@end
