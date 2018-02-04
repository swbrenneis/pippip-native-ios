//
//  NSData+HexEncode.h
//  SeAccountPlugin
//
//  Created by Steve Brenneis on 10/4/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (HexEncode)

+ (instancetype)dataWithHexString:(NSString*)hex withError:(NSError**)error;

- (NSString*) encodeHexString;

@end
