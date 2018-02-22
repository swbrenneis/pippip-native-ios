//
//  Conversation.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Conversation : NSObject

@property (nonatomic) NSUInteger count;

- (instancetype)initWithMessages:(NSArray*)messages;

- (NSArray*)allMessages;

- (NSDictionary*)getIndexedMessage:(NSUInteger)index;

- (NSArray*)getPendingMessages;

- (NSInteger)markMessageRead:(NSDictionary*)triplet;

- (NSInteger)messageExists:(NSDictionary*)triplet;

@end
