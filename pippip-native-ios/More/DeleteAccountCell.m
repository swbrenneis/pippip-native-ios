//
//  DeleteAccountCell.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/21/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "DeleteAccountCell.h"
#import "ApplicationSingleton.h"
#import "UserVault.h"
#import "Authenticator.h"
#import <Realm/Realm.h>

@implementation DeleteAccountCell

+ (MoreCellItem*)cellItem {

    MoreCellItem *item = [[MoreCellItem alloc] init];
    item.cellHeight = 45.0;
    item.cellReuseId = @"DeleteAccountCell";
    return item;

}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        [self validateDelete];
    }

}

- (BOOL)deleteUser {

    NSFileManager *manager = [NSFileManager defaultManager];
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    NSArray<NSURL *> *realmFileURLs = @[
                                        config.fileURL,
                                        [config.fileURL URLByAppendingPathExtension:@"lock"],
                                        [config.fileURL URLByAppendingPathExtension:@"note"],
                                        [config.fileURL URLByAppendingPathExtension:@"management"]
                                        ];
    for (NSURL *URL in realmFileURLs) {
        NSError *error = nil;
        [manager removeItemAtURL:URL error:&error];
        if (error) {
            // handle error
        }
    }

    SessionState *sessionState = [ApplicationSingleton instance].accountSession.sessionState;
    NSString *accountName = sessionState.currentAccount;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *vaultsPath = [docPath stringByAppendingPathComponent:@"PippipVaults"];
    NSString *vaultPath = [vaultsPath stringByAppendingPathComponent:accountName];
    return [manager removeItemAtPath:vaultPath error:nil];

}

- (void)validateDelete {

    NSString *message = @"You are about to delete this account.\nThis action cannot be undone.\nEnter your passphrase to proceed.";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"CAUTION!"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        textField.placeholder = @"Passphrase";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action){
                                                         NSString *passphrase = alert.textFields[0].text;
                                                         [self validatePassphrase:passphrase];
                                                     }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"alert"] = alert;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PresentAlert" object:nil userInfo:info];

}

- (void)validatePassphrase:(NSString*)passphrase {

    SessionState *sessionState = [ApplicationSingleton instance].accountSession.sessionState;
    NSString *accountName = sessionState.currentAccount;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *vaultsPath = [docPath stringByAppendingPathComponent:@"PippipVaults"];
    NSString *vaultPath = [vaultsPath stringByAppendingPathComponent:accountName];
    NSData *vaultData = [NSData dataWithContentsOfFile:vaultPath];
    
    UserVault *vault = [[UserVault alloc] initWithState:sessionState];
    NSError *error = nil;
    [vault decode:vaultData withPassword:passphrase withError:&error];
    if (error == nil) {
        Authenticator *auth = [[Authenticator alloc] init];
        [auth logout];
        [self deleteUser];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountDeleted" object:nil];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Passphrase"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alert addAction:okAction];
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        info[@"alert"] = alert;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PresentAlert" object:nil userInfo:info];
    }

}

@end
