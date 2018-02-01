//
//  MessagesDatabase.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "MessagesDatabase.h"
#import <Realm/Realm.h>

@interface MessagesDatabase ()
{
    RLMRealm *realm;
}

@property (weak, nonatomic) SessionState *sessionState;

@end

@implementation MessagesDatabase

- (void)addMessage:(Message *)message {

    [realm transactionWithBlock:^{
        [realm addObject:message];
    }];

}

- (NSInteger)messageCountById:(NSString *)senderId {

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"senderId = %@", senderId];
    RLMResults<Message*> *result = [Message objectsWithPredicate:predicate];
    return result.count;
    
}

- (BOOL)loadMessages:(SessionState*)state {

    _sessionState = state;
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    // Use the default directory, but replace the filename with the username
    config.fileURL = [[[config.fileURL URLByDeletingLastPathComponent]
                       URLByAppendingPathComponent:_sessionState.currentAccount]
                      URLByAppendingPathExtension:@"realm"];
    NSError *error;
    realm = [RLMRealm realmWithConfiguration:config error:&error];
    if (realm == nil) {
        NSLog(@"Error opening messages database: %@", [error localizedDescription]);
        return NO;
    }
    else {
        return YES;
    }

}

@end
