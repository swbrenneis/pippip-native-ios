//
//  AccountDeleter.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountDeleter : NSObject

- (BOOL)deleteAccount:(NSString*)accountName;

@end
