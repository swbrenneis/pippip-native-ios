//
//  MoreTableViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "MoreTableViewController.h"
#import "ApplicationSingleton.h"
#import "SessionState.h"
#import "ContactPolicyCell.h"
#import "CleartextMessagesCell.h"
#import "NicknameCell.h"
#import "PublicIdCell.h"
#import "LocalPasswordCell.h"
#import "EditWhitelistCell.h"
#import "DeleteAccountCell.h"
#import "AuthViewController.h"
#import "Authenticator.h"
#import "MoreCellItem.h"

static const NSInteger EDIT_INDEX = 4;

@interface MoreTableViewController ()
{
    AuthViewController *authView;
    BOOL suspended;
    NSMutableArray<MoreCellItem*> *cellItems;
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

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(newSession:) name:@"NewSession" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(appResumed:)
                                               name:@"AppResumed" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(appSuspended:)
                                               name:@"AppSuspended" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(policyChanged:)
                                               name:@"PolicyChanged" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(accountDeleted:)
                                               name:@"AccountDeleted" object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {

    [cellItems removeAllObjects];
    [cellItems addObject:[PublicIdCell cellItem]];
    [cellItems addObject:[NicknameCell cellItem]];
    [cellItems addObject:[LocalPasswordCell cellItem]];
    [cellItems addObject:[ContactPolicyCell cellItem]];

    NSString *policy = [[ApplicationSingleton instance].config getContactPolicy];
    if ([policy isEqualToString:@"whitelist"]) {
        [cellItems addObject:[EditWhitelistCell cellItem]];
    }

    [cellItems addObject:[CleartextMessagesCell cellItem]];
    [cellItems addObject:[DeleteAccountCell cellItem]];

    [self.tableView reloadData];

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(presentAlert:)
                                               name:@"PresentAlert" object:nil];

}

- (void)viewWillDisappear:(BOOL)animated {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PresentAlert" object:nil];

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
            [authView setSuspended:YES];
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
    }
    else {
        [cellItems insertObject:[EditWhitelistCell cellItem] atIndex:EDIT_INDEX];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });

}

- (void)presentAlert:(NSNotification*)notification {

    NSDictionary *info = notification.userInfo;
    UIAlertController *alert = info[@"alert"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });

}

- (void)newSession:(NSNotification*)notification {

    _sessionState = (SessionState*)notification.object;

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return cellItems.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    MoreCellItem *item = cellItems[indexPath.item];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item.cellReuseId forIndexPath:indexPath];
    return cell;
/*
    switch (indexPath.item) {
        case ACCOUNTS:
            cell = [tableView dequeueReusableCellWithIdentifier:@"BasicOptionsCell" forIndexPath:indexPath];
            cell.textLabel.text = @"Account List";
            break;
        case PUBLIC_ID:
            cell = [tableView dequeueReusableCellWithIdentifier:@"PublicIdCell" forIndexPath:indexPath];
            break;
        case CONTACT_POLICY:
            cell = [tableView dequeueReusableCellWithIdentifier:@"ContactPolicyCell" forIndexPath:indexPath];
            [(ContactPolicyCell*)cell setViewController:self];
            break;
        case CLEARTEXT_MESSAGES:
            cell = [tableView dequeueReusableCellWithIdentifier:@"CleartextMessagesCell" forIndexPath:indexPath];
            [(CleartextMessageCell*)cell setViewController:self];
            break;
        case SET_NICKNAME:
            cell = [tableView dequeueReusableCellWithIdentifier:@"NicknameCell" forIndexPath:indexPath];
            [(NicknameCell*)cell setViewController:self];
            break;
        case CHANGE_PASSWORD:
            cell = [tableView dequeueReusableCellWithIdentifier:@"LocalPasswordCell" forIndexPath:indexPath];
            [(LocalPasswordCell*)cell setViewController:self];
            break;
        case CONTACT_REQUESTS:
            cell = [tableView dequeueReusableCellWithIdentifier:@"BasicOptionsCell" forIndexPath:indexPath];
            cell.textLabel.text = @"Check Contact Requests";
            break;
        case EDIT_FRIENDS:
            cell = [tableView dequeueReusableCellWithIdentifier:@"BasicOptionsCell" forIndexPath:indexPath];
            cell.textLabel.text = @"Edit Friends List";
            break;
    }
    
    // Configure the cell...
    
    return cell;
 */
}
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.item) {
        case ACCOUNTS:
            [self performSegueWithIdentifier:@"AccountListSegue" sender:self];
            break;
        case CONTACT_REQUESTS:
            [self performSegueWithIdentifier:@"PendingRequestsSegue" sender:self];
            break;
        case EDIT_FRIENDS:
            [self performSegueWithIdentifier:@"WhitelistSegue" sender:self];
            break;
    }

}
*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    id<MultiCellItem> item = cellItems[indexPath.item];
    return item.cellHeight;

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
