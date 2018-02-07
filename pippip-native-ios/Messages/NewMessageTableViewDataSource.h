//
//  NewMessageTableViewDataSource.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/4/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactManager.h"
#import "MessageManager.h"
#import "NewMessageCellSource.h"

@interface NewMessageTableViewDataSource : NSObject <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (readonly, nonatomic) NewMessageCellSource *cellSource;
@property (nonatomic) NSString *selectedId;
@property (nonatomic) NSString *selectedNickname;

@property (weak, nonatomic) UITableView *tableView;

- (instancetype)initWithManagers:(ContactManager*)contact withMessageManager:(MessageManager*)message;

- (void)contactSelected:(NSString*)publicId withNickname:(NSString*)nickname;

@end
