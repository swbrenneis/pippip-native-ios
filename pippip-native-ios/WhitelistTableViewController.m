//
//  WhitelistTableViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/28/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "WhitelistTableViewController.h"
#import "AppDelegate.h"
#import "AccountManager.h"
#import "WhitelistTableViewCell.h"
#import "WhitelistManager.h"
#import "AddFriendViewController.h"
#import "ContactManager.h"

@interface WhitelistTableViewController ()
{
    NSArray *whitelist;
    NSArray *whitelistNicknames;
    WhitelistManager *whitelistManager;

}

@property (weak, nonatomic) AccountManager *accountManager;
@property (weak, nonatomic) ContactManager *contactManager;

@end

@implementation WhitelistTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    // Get the account manager
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _accountManager = delegate.accountManager;
    _contactManager = delegate.contactManager;
    whitelist = _accountManager.config[@"whitelist"];
    if (whitelist == nil) {
        whitelist = [NSArray array];
    }
    else {
        whitelistNicknames = _accountManager.config[@"whitelistNicknames"];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) response:(NSDictionary *)info {
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return whitelist.count;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WhitelistCell" forIndexPath:indexPath];
    WhitelistTableViewCell *whitelistCell = (WhitelistTableViewCell*)cell;

    whitelistCell.nicknameLabel.text = whitelistNicknames[indexPath.item];
    whitelistCell.publicIdLabel.text = whitelist[indexPath.item];

    return cell;
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

#pragma mark - Navigation

- (IBAction) unwindToWhitelistViewController:(UIStoryboardSegue*)segue {
 }

- (IBAction) unwindAfterAddFriend:(UIStoryboardSegue*)segue {

    AddFriendViewController *view = (AddFriendViewController*)segue.sourceViewController;
    [_contactManager setViewController:self];
    NSString *publicId = view.publicIdTextField.text;
    [_contactManager addFriend:publicId];

}

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
