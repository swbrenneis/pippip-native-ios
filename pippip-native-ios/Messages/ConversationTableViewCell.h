//
//  ConversationTableViewCell.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/18/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConversationTableViewCell : UITableViewCell

@property (nonatomic) CGSize contentSize;

- (void)configureCell:(NSMutableDictionary*)message;

@end
