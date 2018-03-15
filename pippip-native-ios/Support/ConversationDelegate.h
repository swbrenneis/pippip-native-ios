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
@property (readonly, nonatomic) NSString *publicId;

- (instancetype)initWithPublicId:(NSString*)publicId;

- (void)acknowledgeMessage:(NSInteger)messageId;

- (void)addMessage:(NSMutableDictionary*)message;

- (NSArray*)allMessageIds;

- (void)deleteAllMessages;

- (void)deleteMessage:(NSInteger)messageId;

- (NSMutableDictionary*)getMessage:(NSInteger)messageId;

- (void)markMessageRead:(NSInteger)messageId;

//- (NSInteger)messageExists:(NSDictionary*)triplet;

//- (NSArray*)pendingMessages;

@end
