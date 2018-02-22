//
//  ConversationViewController.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/11/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageObserver.h"
#import "ResponseConsumer.h"

@interface ConversationViewController : UIViewController <MessageObserver, ResponseConsumer>

@property (nonatomic) NSString *publicId;

@end
