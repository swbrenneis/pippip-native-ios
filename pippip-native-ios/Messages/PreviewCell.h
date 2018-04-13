//
//  PreviewCell.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TextMessage;

@interface PreviewCell : UITableViewCell

- (void)configure:(TextMessage*_Nonnull)message;

- (TextMessage*_Nonnull)getTextMessage;

@end
