//
//  ContactsTableViewController.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/9/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResponseConsumer.h"
#import "ContactObserver.h"

@interface ContactsTableViewController : UITableViewController <ResponseConsumer, ContactObserver>

@end
