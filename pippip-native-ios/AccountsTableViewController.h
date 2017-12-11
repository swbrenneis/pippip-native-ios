//
//  AccountsTableViewController.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountManager.h"

@interface AccountsTableViewController : UITableViewController

@property (weak, nonatomic) AccountManager *accountManager;

@end
