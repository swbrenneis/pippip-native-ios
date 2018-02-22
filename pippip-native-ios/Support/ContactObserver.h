//
//  ContactObserver.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/17/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ContactObserver <NSObject>

- (void)contactsUpdated;

@optional
- (void)contactUpdate:(NSDictionary*)contact;

@end
