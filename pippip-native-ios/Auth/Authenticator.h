//
//  Authenticator.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/1/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Authenticator : NSObject <RequestProcessProtocol>

- (void)logout;

- (void)localAuthenticate:(NSString*)accountName withPassphrase:(NSString*)passphrase;

@end
