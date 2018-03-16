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

- (instancetype)initWithPublicId:(NSString*)publicId;

- (NSArray*)allMessageIds;

- (NSUInteger)count;

- (NSMutableDictionary*)getMessage:(NSUInteger)messageId;

- (NSArray*)latestMessageIds:(NSInteger)count;

@end
