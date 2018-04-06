//
//  MoreTableViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "MoreTableViewController.h"
#import "pippip_native_ios-Swift.h"
#import "ApplicationSingleton.h"
#import "ContactPolicyCell.h"
#import "CleartextMessagesCell.h"
#import "NicknameCell.h"
#import "LocalPasswordCell.h"
#import "Authenticator.h"
#import "Notifications.h"
#import "MoreCellItem.h"
#import "RKDropdownAlert.h"
#import "Chameleon.h"

static const NSInteger EDIT_INDEX = 4;

@interface MoreTableViewController ()
{
    AuthViewController *authView;
    BOOL suspended;
    NSMutableArray<MoreCellItem*> *cellItems;
    MoreCellItem *deleteItem;
    UIView *headingView;
    NicknameCell *nicknameCell;
}

@property (weak, nonatomic) SessionState *sessionState;

@end

@implementation MoreTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _sessionState = [ApplicationSingleton instance].accountSession.sessionState;
    authView = [self.storyboard instantiateViewControllerWithIdentifier:@"AuthViewController"];
    suspended = NO;
    cellItems = [NSMutableArray array];
    deleteItem = [DeleteAccountCell cellItem];
    nicknameCell = [self.tableView dequeueReusableCellWithIdentifier:@"NicknameCell"];

    headingView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 40.0)];
    headingView.backgroundColor = [UIColor colorNamed:@"Pale Gray"];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(newSession:)
                                               name:NEW_SESSION object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(appResumed:)
                                               name:APP_RESUMED object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(appSuspended:)
                                               name:APP_SUSPENDED object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(policyChanged:)
                                               name:POLICY_CHANGED object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(accountDeleted:)
                                               name:@"AccountDeleted" object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [cellItems addObject:[PublicIdCell cellItem]];
    MoreCellItem *nicknameItem = [NicknameCell cellItem];
    nicknameItem.currentCell = nicknameCell;
    [cellItems addObject:nicknameItem];
    [cellItems addObject:[LocalPasswordCell cellItem]];
    [cellItems addObject:[CleartextMessagesCell cellItem]];
    [cellItems addObject:[ContactPolicyCell cellItem]];
    
    NSString *policy = [[ApplicationSingleton instance].config getContactPolicy];
    if ([policy isEqualToString:@"whitelist"]) {
        [cellItems addObject:[EditWhitelistCell cellItem]];
    }

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(presentAlert:)
                                               name:PRESENT_ALERT object:nil];
    [NSNotificationCenter.defaultCenter addObserver:nicknameCell
                                           selector:@selector(newSession:)
                                               name:NEW_SESSION object:nil];
    [NSNotificationCenter.defaultCenter addObserver:nicknameCell
                                           selector:@selector(nicknameUpdated:)
                                               name:NICKNAME_UPDATED object:nil];
    [NSNotificationCenter.defaultCenter addObserver:nicknameCell
                                           selector:@selector(nicknameMatched:)
                                               name:NICKNAME_MATCHED object:nil];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:PRESENT_ALERT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:nicknameCell name:NEW_SESSION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:nicknameCell name:NICKNAME_MATCHED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:nicknameCell name:NICKNAME_UPDATED object:nil];

}

- (void)accountDeleted:(NSNotification*)notification {

    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"AccountDeletedSegue" sender:self];
    });

}

- (void)appResumed:(NSNotification*)notification {

    if (suspended) {
        suspended = NO;
        NSDictionary *info = notification.userInfo;
        NSInteger suspendedTime = [info[@"suspendedTime"] integerValue];
        if (suspendedTime > 0 && suspendedTime < 180) {
            authView.suspended = YES;
        }
        else {
            Authenticator *auth = [[Authenticator alloc] init];
            [auth logout];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.view.window != nil) {
                [self presentViewController:authView animated:YES completion:nil];
            }
        });
    }
    
}

- (void)appSuspended:(NSNotification*)notification {
    
    suspended = YES;
    
}

- (void)policyChanged:(NSNotification*)notification {

    NSDictionary *info = notification.userInfo;
    NSString *policy = info[@"policy"];
    if ([policy isEqualToString:@"public"]) {
        [cellItems removeObjectAtIndex:EDIT_INDEX];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *path = [NSIndexPath indexPathForRow:5 inSection:0];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:path, nil]
                                  withRowAnimation:UITableViewRowAnimationLeft];
        });
    }
    else {
        [cellItems insertObject:[EditWhitelistCell cellItem] atIndex:EDIT_INDEX];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *path = [NSIndexPath indexPathForRow:5 inSection:0];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:path, nil]
                                  withRowAnimation:UITableViewRowAnimationRight];
        });
    }

}

- (void)presentAlert:(NSNotification*)notification {

    NSDictionary *info = notification.userInfo;
    NSString *title = info[@"title"];
    NSString *message = info[@"message"];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIColor *alertColor = UIColor.flatSandColor;
        [RKDropdownAlert title:title message: message backgroundColor:alertColor
                     textColor:ContrastColor(alertColor, true) time:2 delegate:nil];
    });

}

- (void)newSession:(NSNotification*)notification {

    _sessionState = (SessionState*)notification.object;

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return cellItems.count;
    }
    else {
        return 1;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        MoreCellItem *item = cellItems[indexPath.item];
        if (item.currentCell != nil) {
            if ([item.currentCell isKindOfClass:TableViewCellWithController.class]) {
                ((TableViewCellWithController*)item.currentCell).viewController = self;
            }
            return item.currentCell;
        }
        else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item.cellReuseId forIndexPath:indexPath];
            item.currentCell = cell;
            if ([cell isKindOfClass:TableViewCellWithController.class]) {
                ((TableViewCellWithController*)cell).viewController = self;
            }
            return cell;
        }
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:deleteItem.cellReuseId
                                                                forIndexPath:indexPath];
        ((DeleteAccountCell*)cell).viewController = self;
        return cell;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        id<MultiCellItem> item = cellItems[indexPath.item];
        return item.cellHeight;
    }
    else {
        return deleteItem.cellHeight;
    }

}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    if (section == 1) {
        return headingView;
    }
    else {
        return nil;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    if (section == 1) {
        return 40.0;
    }
    else {
        return 0.0;
    }
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
