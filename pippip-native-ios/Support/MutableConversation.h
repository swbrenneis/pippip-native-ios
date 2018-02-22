//
//  MutableConversation.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/20/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "Conversation.h"

@interface MutableConversation : Conversation

- (void)acknowledgeMessage:(NSDictionary*)triplet;

- (void)addMessage:(NSMutableDictionary*)message;

- (NSInteger)markMessageRead:(NSDictionary*)triplet;

@end
