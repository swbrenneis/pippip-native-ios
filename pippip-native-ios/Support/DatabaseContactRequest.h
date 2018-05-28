//
//  DatabaseContactRequest.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/26/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Realm/Realm.h>

@interface DatabaseContactRequest : RLMObject

@property NSString *publicId;
@property NSString *nickname;

@end
