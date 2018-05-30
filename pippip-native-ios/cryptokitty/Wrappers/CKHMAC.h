//
//  CKHMAC.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/4/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKHMAC : NSObject

- (instancetype _Nonnull) initWithSHA256;

- (BOOL) authenticate:(NSData*_Nonnull)message;

- (NSData*_Nonnull) getHMAC;

- (void) setKey:(NSData*_Nonnull)key;

- (void) setMessage:(NSData*_Nonnull)message;

@end
