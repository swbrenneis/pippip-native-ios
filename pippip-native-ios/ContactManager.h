//
//  ContactManager.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/12/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestProcess.h"
#import "AccountManager.h"
#import "ResponseConsumer.h"

@interface ContactManager : NSObject <RequestProcess>

- (instancetype)initWithAccountManager:(AccountManager*)manager;

- (void)addContact:(NSMutableDictionary*)entity;

- (void)addFriend:(NSString*)publicId;

- (NSInteger)contactCount;

- (void)deleteFriend:(NSString*)publicId;

- (NSDictionary*)contactAtIndex:(NSInteger)index;

- (void)loadContacts;

- (void)matchNickname:(NSString*)nickname;

- (void)setContactPolicy:(NSString*)policy;

- (void)setNickname:(NSString*)nickname;

- (void)setResponseConsumer:(id<ResponseConsumer>)consumer;

- (void)setViewController:(UIViewController*)controller;

- (void)storeContacts;

- (void)requestContact:(NSString*)publicId;

@end
