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
#import "ContactEntity.h"
#import "ResponseConsumer.h"

@interface ContactManager : NSObject <RequestProcess>

- (instancetype)initWithAccountManager:(AccountManager*)manager;

- (void)addFriend:(NSString*)publicId;

- (NSInteger)count;

- (NSString*)currentNickname;

- (ContactEntity*)entityAtIndex:(NSInteger)index;

- (void)matchNickname:(NSString*)nickname;

- (void)setContactPolicy;

- (void)setNickname:(NSString*)nickname;

- (void)setResponseConsumer:(id<ResponseConsumer>)consumer;

- (void)setViewController:(UIViewController*)controller;

- (void)requestContact:(ContactEntity*)entity;

@end
