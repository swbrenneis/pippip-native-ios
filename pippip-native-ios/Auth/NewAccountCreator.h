//
//  NewAccountCreator.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewAccountCreator : NSObject <RequestProcessProtocol>

- (void) createAccount:(NSString*)accountName withPassphrase:(NSString*)passphrase;

@end
