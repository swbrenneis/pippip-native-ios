//
//  ContactSearchDataSource.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/5/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewMessageTableViewDataSource.h"

@interface ContactSearchDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) NewMessageTableViewDataSource *messageSource;
@property (nonatomic) NSInteger rowsInTable;

- (void)setContactList:(NSArray*)contacts;

@end
