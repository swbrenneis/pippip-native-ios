//
//  WhitelistTableViewController.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/28/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResponseConsumer.h"

@interface WhitelistTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, ResponseConsumer>

@end
