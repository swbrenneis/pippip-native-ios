//
//  CKHMAC.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/4/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKHMAC : NSObject

- (instancetype) initWithSHA256;

- (BOOL) authenticate:(NSData*)message;

- (NSData*) getHMAC;

- (void) setKey:(NSData*)key;

- (void) setMessage:(NSData*)message;

@end
