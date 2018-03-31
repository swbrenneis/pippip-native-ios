//
//  Authenticator.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/1/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestProcess.h"
#import "RESTSession.h"

@interface Authenticator : NSObject <RequestProcess>

- (void)authenticate:(NSString*)accountName withPassphrase:(NSString*)passphrase;

- (void)localAuthenticate:(NSString*)accountName withPassphrase:(NSString*)passphrase;

- (void)logout;

@end
