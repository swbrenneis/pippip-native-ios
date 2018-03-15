//
//  AccountConfig.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/12/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Realm/Realm.h>

@interface AccountConfig : RLMObject

@property (nonatomic) float version;
@property (nonatomic) NSString *accountName;
@property (nonatomic) NSString *nickname;
@property (nonatomic) NSString *contactPolicy;
@property (nonatomic) NSInteger messageId;
@property (nonatomic) NSInteger contactId;
@property (nonatomic) NSData *whitelist;
@property (nonatomic) NSData *idMap;
@property (nonatomic) BOOL cleartextMessages;

@end
