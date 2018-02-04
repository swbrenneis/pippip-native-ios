//
//  PendingContactViewController.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResponseConsumer.h"

@interface PendingContactViewController : UIViewController <ResponseConsumer>

@property (nonatomic) NSString *requestNickname;
@property (nonatomic) NSString *requestPublicId;

@end
