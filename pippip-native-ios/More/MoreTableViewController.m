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
#import "NicknameCell.h"

static const NSInteger ACCOUNTS = 0;
static const NSInteger PUBLIC_ID = 1;
static const NSInteger CONTACT_POLICY = 2;
static const NSInteger SET_NICKNAME = 3;
static const NSInteger CONTACT_REQUESTS = 4;
static const NSInteger EDIT_FRIENDS = 5;

@interface MoreTableViewController ()

@property (weak, nonatomic) SessionState *sessionState;

@end

@implementation MoreTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _sessionState = [ApplicationSingleton instance].accountSession.sessionState;
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:_activityIndicator];
    _activityIndicator.center = self.view.center;

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(newSession:) name:@"NewSession" object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)newSession:(NSNotification*)notification {

    _sessionState = (SessionState*)notification.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSString *contactPolicy = [[ApplicationSingleton instance].config getContactPolicy];
    if ([contactPolicy isEqualToString:@"public"]) {
        return 5;
    }
    else {
        return 6;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = nil;
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
        case SET_NICKNAME:
            cell = [tableView dequeueReusableCellWithIdentifier:@"NicknameCell" forIndexPath:indexPath];
            [(NicknameCell*)cell setViewController:self];
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
}

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.item) {
        case PUBLIC_ID:
            return 51.0;
        default:
            return 44.0;
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
