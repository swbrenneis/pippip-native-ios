//
//  AddContactViewController.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/12/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResponseConsumer.h"

@interface AddContactViewController : UIViewController <ResponseConsumer>

@property (nonatomic) NSMutableDictionary *addedContact;

@end
