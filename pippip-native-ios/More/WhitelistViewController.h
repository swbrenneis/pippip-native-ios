//
//  WhitelistViewController.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/23/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResponseConsumer.h"

@interface WhitelistViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ResponseConsumer>

- (void)cancelAddFriend;

- (void)addFriend:(NSString*)nickname withPublicId:(NSString*)publicId;

@end
