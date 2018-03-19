//
//  NewMessageDataSource.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/19/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewMessageViewController.h"

@interface NewMessageDataSource : NSObject <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

- (instancetype)initWithTableView:(UITableView*)newMeaasgeTableView;

- (NSDictionary*)getSelectedContact;

- (void)searchFieldChanged:(NSString*)partial;

@end
