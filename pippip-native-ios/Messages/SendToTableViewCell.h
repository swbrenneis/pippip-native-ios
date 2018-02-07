//
//  SendToTableViewCell.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/4/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendToTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *sendToTextView;

@property (nonatomic) NSString *publicId;

@end
