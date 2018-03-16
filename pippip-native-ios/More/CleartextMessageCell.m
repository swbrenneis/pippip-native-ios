//
//  CleartextMessageCell.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "CleartextMessageCell.h"
#import "ApplicationSingleton.h"
#import "MBProgressHUD.h"
#import "MessagesDatabase.h"

@interface CleartextMessageCell ()
{

}

@property (weak, nonatomic) IBOutlet UISwitch *cleartextMessagesSwitch;
@property (weak, nonatomic) MoreTableViewController *viewController;

@end

@implementation CleartextMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [_cleartextMessagesSwitch setOn:![[ApplicationSingleton instance].config getCleartextMessages]];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)cleartextSelected:(UISwitch *)sender {

    if (sender.on) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_viewController.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = @"Scrubbing messages";
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ApplicationSingleton instance].config setCleartextMessages:NO];
            MessagesDatabase *messageDatabase = [[MessagesDatabase alloc] init];
            [messageDatabase scrubCleartext];
            [MBProgressHUD hideHUDForView:_viewController.view animated:YES];
        });
    }
    else {
        NSString *cleartextMessage = @"Disabling extra message security will result in a performance increase but your messages could potentially be read if your device is lost or stolen. Do you want to continue?";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Caution!"
                                                                       message:cleartextMessage
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_viewController.view animated:YES];
                                                              hud.mode = MBProgressHUDModeIndeterminate;
                                                              hud.label.text = @"Decrypting messages";
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  [[ApplicationSingleton instance].config setCleartextMessages:YES];
                                                                  MessagesDatabase *messageDatabase = [[MessagesDatabase alloc] init];
                                                                  [messageDatabase decryptAll];
                                                                  [MBProgressHUD hideHUDForView:_viewController.view animated:YES];
                                                              });
                                                          }];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
        [alert addAction:yesAction];
        [alert addAction:noAction];
        [_viewController presentViewController:alert animated:YES completion:nil];
    }

}

- (void)setViewController:(MoreTableViewController *)view {
    _viewController = view;
}

@end
