//
//  ContactDetailViewController.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/22/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResponseConsumer.h"

@interface ContactDetailViewController : UIViewController <ResponseConsumer>

@property (weak, nonatomic) NSDictionary *contact;

@end
