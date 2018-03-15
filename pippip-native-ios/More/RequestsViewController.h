//
//  RequestsViewController.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/28/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResponseConsumer.h"
#import "MoreTableViewController.h"

@interface RequestsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ResponseConsumer>

@end
