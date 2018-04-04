//
//  UserVault.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 11/30/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SessionState;

@interface UserVault : NSObject

- (instancetype) initWithState:(SessionState*)state;

-(void) decode:(NSData*)data withPassword:(NSString*) password withError:(NSError**)error;

- (NSData*) encode:(NSString*) password;

@end
