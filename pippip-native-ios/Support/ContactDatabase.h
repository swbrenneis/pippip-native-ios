//
//  ContactDatabase.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionState.h"

@interface ContactDatabase : NSObject

- (NSInteger)addContact:(NSMutableDictionary*)contact;

- (void)deleteContact:(NSString*)publicId;

- (NSMutableDictionary*)getContact:(NSString*)publicId;

- (NSMutableDictionary*)getContactById:(NSInteger)contactId;

- (NSArray*)getContactList;

- (void)updateContact:(NSMutableDictionary*)contact;

@end
