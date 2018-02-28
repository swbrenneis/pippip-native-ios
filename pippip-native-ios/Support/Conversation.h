//
//  Conversation.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Conversation : NSObject

@property (readonly, nonatomic) id delegate;

- (instancetype)initWithMessages:(NSArray*)messages;

- (NSArray*)allMessages;

- (NSUInteger)count;

- (NSDictionary*)getIndexedMessage:(NSUInteger)index;

- (NSInteger)messageExists:(NSDictionary*)triplet;

//- (NSArray*)pendingMessages;

@end
