//
//  ConversationDelegate.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/22/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ConversationDelegate.h"
#import "CKSHA1.h"

@interface ConversationDelegate ()
{
    // Array of messages
    NSMutableArray *messageList;
    // Dictionary of hash to message
    NSMutableDictionary *conversation;
}

@end

@implementation ConversationDelegate

- (instancetype)init {
    self = [super init];
    
    messageList = [NSMutableArray array];
    conversation = [NSMutableDictionary dictionary];

    return self;
    
}

- (instancetype)initWithMessages:(NSArray *)messages {
    self = [super init];
    
    messageList = [NSMutableArray array];
    conversation = [NSMutableDictionary dictionary];
    for (NSMutableDictionary *message in messages) {
        conversation[[self getMessageHash:message]] = message;
        [self addMessageSorted:message];
    }
    _count = conversation.count;
    
    return self;
    
}

- (void)acknowledgeMessage:(NSDictionary *)triplet {
    
    NSString *hash = [self getMessageHash:triplet];
    NSMutableDictionary *message = conversation[hash];
    message[@"acknowledged"] = @YES;
    
}

- (void)addMessage:(NSMutableDictionary *)message {
    
    NSString *hash = [self getMessageHash:message];
    if (conversation[hash] == nil) {
        conversation[hash] = message;
        if (messageList.count == 0) {
            [self sortMessages];
        }
        [self addMessageSorted:message];
    }
    _count = conversation.count;
    
}

- (void)addMessageSorted:(NSDictionary*)message {
    
    if (messageList.count == 0) {
        [messageList addObject:message];
    }
    else {
        // Add the message in sorted order.
        NSUInteger index = [messageList indexOfObject:message
                                        inSortedRange:(NSRange){0, messageList.count}
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
        [messageList insertObject:message atIndex:index];
    }
    
}

- (NSArray*)allMessages {
    
    if (messageList.count == 0) {
        [self sortMessages];
    }
    return messageList;
    
}

- (void)deleteAllMessages {

    [conversation removeAllObjects];
    [messageList removeAllObjects];
    _count = 0;

}

- (void)deleteMessage:(NSDictionary *)triplet {

    NSString *hash = [self getMessageHash:triplet];
    [conversation removeObjectForKey:hash];
    [self sortMessages];
    _count = conversation.count;

}

- (NSDictionary*)getIndexedMessage:(NSUInteger)index {
    
    if (messageList.count == 0) {
        [self sortMessages];
    }
    return messageList[index];
    
}

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

- (NSInteger)markMessageRead:(NSDictionary*)triplet {
    
    NSString *hash = [self getMessageHash:triplet];
    NSMutableDictionary *message = conversation[hash];
    message[@"read"] = @YES;
    return [message[@"messageId"] integerValue];
    
}

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
/*
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
*/
- (void)sortMessages {
    
    [messageList removeAllObjects];
    if (conversation.count > 0) {
        for (NSString *hash in conversation) {
            [self addMessageSorted:conversation[hash]];
        }
    }
    
}

@end
