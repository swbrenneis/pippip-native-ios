//
//  HexCodec.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/22/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HexCodec : NSObject

+ (NSString*)hexString:(NSData*)binary;

@end
