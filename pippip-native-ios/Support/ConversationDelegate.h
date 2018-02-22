//
//  ConversationDelegate.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/22/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConversationDelegate : NSObject

@property (nonatomic) NSUInteger count;

- (instancetype)initWithMessages:(NSArray*)messages;

- (void)acknowledgeMessage:(NSDictionary*)triplet;

- (void)addMessage:(NSMutableDictionary*)message;

- (NSArray*)allMessages;

- (NSDictionary*)getIndexedMessage:(NSUInteger)index;

- (NSArray*)getPendingMessages;

- (NSInteger)markMessageRead:(NSDictionary*)triplet;

- (NSInteger)messageExists:(NSDictionary*)triplet;

@end
