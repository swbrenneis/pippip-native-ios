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

@property (nonatomic) NSMutableArray *indexed;
@property (nonatomic) NSMutableDictionary *keyed;

- (void)addContact:(NSMutableDictionary*)contact;

- (void)deleteContact:(NSString*)publicId;

- (BOOL)loadContacts:(SessionState*)state;

- (void)syncContacts:(NSArray*)synched;

- (void)updateContact:(NSMutableDictionary*)contact;

@end
