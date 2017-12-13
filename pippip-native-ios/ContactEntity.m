//
//  ContactEntity.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/12/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "ContactEntity.h"

@implementation ContactEntity

- (instancetype)initWithPublicId:(NSString*)puId withNickname:(NSString*)nick {
    self = [super init];
    
    _publicId = puId;
    _nickname = nick;
    _status = PENDING;

    return self;

}

- (NSString*) imageName {

    switch (_status) {
        case ACCEPTED:
            return @"approved";
        case REJECTED:
            return @"rejected";
        case PENDING:
            return @"pending";
    }

}

@end
