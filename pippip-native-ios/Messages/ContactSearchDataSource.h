//
//  ContactSearchDataSource.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/5/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactSearchDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

- (void)setContactList:(NSArray*)contacts;

- (NSDictionary*)contactAtRow:(NSInteger)row;

@end
