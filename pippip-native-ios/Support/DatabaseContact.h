//
//  DatabaseContact.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Realm/Realm.h>

@interface DatabaseContact : RLMObject

@property NSInteger contactId;
@property NSData *encoded;

@end
