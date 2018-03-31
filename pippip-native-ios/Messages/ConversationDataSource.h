//
//  ConversationDataSource.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/11/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SessionState;

@interface ConversationDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

//- (instancetype)initWithTableView:(UITableView*)tableView;

- (instancetype)initWithTableView:(UITableView*)tableView withPublicId:(NSString*)pid;

- (NSInteger)getMessageCount;

- (void)messagesCleared;

- (void)messagesUpdated:(NSNotification*)notification;

@end
