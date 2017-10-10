//
//  ParameterGenerator.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "SessionState.h"

@interface ParameterGenerator : SessionState

- (void)generateParameters:(NSString*)accountName;

@end
