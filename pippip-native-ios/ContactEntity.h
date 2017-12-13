//
//  ContactEntity.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/12/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum { PENDING, ACCEPTED, REJECTED } Status;

@interface ContactEntity : NSObject

- (instancetype) initWithPublicId:(NSString*)puId withNickname:(NSString*)nick;

@property (nonatomic, readonly) NSString *nickname;
@property (nonatomic, readonly) NSString *publicId;
@property (nonatomic) Status status;

@end
