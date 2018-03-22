//
//  CleartextMessagesCell.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "CleartextMessagesCell.h"
#import "ApplicationSingleton.h"
#import "MBProgressHUD.h"
#import "MessagesDatabase.h"

@interface CleartextMessagesCell ()
{

}

@property (weak, nonatomic) IBOutlet UISwitch *cleartextMessagesSwitch;

@end

@implementation CleartextMessagesCell

+ (MoreCellItem*)cellItem {

    MoreCellItem *item = [[MoreCellItem alloc] init];
    item.cellHeight = 65.0;
    item.cellReuseId = @"CleartextMessagesCell";
    return item;

}

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
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.superview animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = @"Scrubbing messages";
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ApplicationSingleton instance].config setCleartextMessages:NO];
            MessagesDatabase *messageDatabase = [[MessagesDatabase alloc] init];
            [messageDatabase scrubCleartext];
            [MBProgressHUD hideHUDForView:self.superview animated:YES];
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
                                                              MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.superview animated:YES];
                                                              hud.mode = MBProgressHUDModeIndeterminate;
                                                              hud.label.text = @"Decrypting messages";
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  [[ApplicationSingleton instance].config setCleartextMessages:YES];
                                                                  MessagesDatabase *messageDatabase = [[MessagesDatabase alloc] init];
                                                                  [messageDatabase decryptAll];
                                                                  [MBProgressHUD hideHUDForView:self.superview animated:YES];
                                                              });
                                                          }];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action){
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 [sender setOn:YES];
                                                             });
                                                         }];
        [alert addAction:yesAction];
        [alert addAction:noAction];
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        info[@"alert"] = alert;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PresentAlert" object:nil userInfo:info];
    }

}
/*
- (void)setViewController:(MoreTableViewController *)view {
    _viewController = view;
}
*/
@end
