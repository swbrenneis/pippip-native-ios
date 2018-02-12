//
//  ConversationDataSource.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/11/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConversationDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

- (void)setConversation:(NSArray *)conversation;

@end
