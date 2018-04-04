//
//  LocalPasswordCell.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/20/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "LocalPasswordCell.h"
#import "pippip_native_ios-Swift.h"
#import "ApplicationSingleton.h"
#import "UserVault.h"

@interface LocalPasswordCell ()

@property (weak, nonatomic) IBOutlet UIButton *changePasswordButton;
@property (weak, nonatomic) IBOutlet UITextField *passphraseTextField;

@end

@implementation LocalPasswordCell

+ (MoreCellItem*)cellItem {

    MoreCellItem *item = [[MoreCellItem alloc] init];
    item.cellReuseId = @"LocalPasswordCell";
    item.cellHeight = 65.0;
    return item;

}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _changePasswordButton.alpha = 0.0;
    [_changePasswordButton setEnabled:NO];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
/*
- (void)setViewController:(UIViewController *)view {
    _moreView = view;
}
*/
- (void)checkPassphrase:(NSString*)passphrase {

    if (_passphraseTextField.text.length > 0) {
        [self doChangePassphrase:passphrase];
    }
    else {

        NSString *message = @"Empty passphrases are not recommended.\nTap 'Ok' to continue, 'Cancel' to start over";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Empty Passphrase"
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action){
                                                             [self doChangePassphrase:passphrase];
                                                         }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action) {
                                                                 _passphraseTextField.text = @"***********";
                                                                 _changePasswordButton.alpha = 0.0;
                                                                 [_changePasswordButton setEnabled:NO];
                                                             }];
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        info[@"alert"] = alert;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PresentAlert" object:nil userInfo:info];

    }

}

- (void)doChangePassphrase:(NSString*)passphrase {

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
        [self storeVault:sessionState withPassphrase:_passphraseTextField.text];
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
        _passphraseTextField.text = @"***********";
        _changePasswordButton.alpha = 0.0;
        [_changePasswordButton setEnabled:NO];
    }

}

- (void)storeVault:(SessionState*)sessionState withPassphrase:(NSString*)passphrase {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *vaultsPath = [docPath stringByAppendingPathComponent:@"PippipVaults"];
    NSString *vaultPath = [vaultsPath stringByAppendingPathComponent:sessionState.currentAccount];
    
    UserVault *vault = [[UserVault alloc] initWithState:sessionState];
    NSData *vaultData = [vault encode:passphrase];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:vaultsPath
           withIntermediateDirectories:NO
                            attributes:nil
                                 error:nil];
    [vaultData writeToFile:vaultPath atomically:YES];
    _passphraseTextField.text = @"***********";
    _changePasswordButton.alpha = 0.0;
    [_changePasswordButton setEnabled:NO];

}

- (IBAction)passwordChanged:(UITextField *)sender {

    _changePasswordButton.alpha = 1.0;
    [_changePasswordButton setEnabled:YES];
    
}

- (IBAction)changePassword:(id)sender {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Change Local Passphrase"
                                                                   message:@"Enter your current passphrase" preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        textField.placeholder = @"Passphrase";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action){
                                                         NSString *passphrase = alert.textFields[0].text;
                                                         [self checkPassphrase:passphrase];
                                                     }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action){
                                                             _passphraseTextField.text = @"***********";
                                                             _changePasswordButton.alpha = 0.0;
                                                             [_changePasswordButton setEnabled:NO];
                                                         }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"alert"] = alert;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PresentAlert" object:nil userInfo:info];

}

@end
