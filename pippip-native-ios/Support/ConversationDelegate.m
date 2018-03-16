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

- (void)markMessageRead:(NSInteger)messageId {
    
    NSMutableDictionary *message = conversation[[NSNumber numberWithInteger:messageId]];
    message[@"read"] = @YES;
    
}

- (NSArray*)latestMessageIds:(NSInteger)count {

    NSMutableArray *latest = [NSMutableArray array];
    NSArray *ids = [messageDatabase loadMessageIds:_publicId];
    for (NSInteger index = ids.count - count; latest.count < count; index++) {
        [latest addObject:ids[index]];
    }
    return latest;

}

@end
