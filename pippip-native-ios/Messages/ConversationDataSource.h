//
//  ConversationDataSource.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/11/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SessionState.h"

@interface ConversationDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithPublicId:(NSString*)pid;

- (void)messagesUpdated;

@end
