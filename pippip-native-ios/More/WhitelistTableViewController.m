//
//  WhitelistTableViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/28/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "WhitelistTableViewController.h"
#import "AppDelegate.h"
#import "Configurator.h"
#import "WhitelistTableViewCell.h"
#import "AddFriendViewController.h"
#import "ContactManager.h"

@interface WhitelistTableViewController ()
{
    NSDictionary *deletedEntity;
    NSIndexPath *deletedIndex;
    NSString *accountName;
    Configurator *config;
}

@property (weak, nonatomic) ContactManager *contactManager;

@end

@implementation WhitelistTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void)viewWillAppear:(BOOL)animated {

    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    accountName = delegate.accountSession.sessionState.currentAccount;
    _contactManager = delegate.accountSession.contactManager;
    config = [[Configurator alloc] initWithSessionState:delegate.accountSession.sessionState];
    [config loadWhitelist];
    [self.tableView reloadData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) response:(NSDictionary *)info {

    NSString *result = info[@"result"];
    if ([result isEqualToString:@"not found"]) {
        NSString *publicId = deletedEntity[@"publicId"];
        NSLog(@"%@ %@ %@", @"Friend", publicId, @"not found on server");
    }

    [config deleteWhitelistEntry:deletedEntity[@"publicId"]];
    UITableView *tableView = self.tableView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [tableView deleteRowsAtIndexPaths:@[deletedIndex] withRowAnimation:UITableViewRowAnimationFade];
    });

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return config.whitelist.count;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WhitelistCell" forIndexPath:indexPath];
    WhitelistTableViewCell *whitelistCell = (WhitelistTableViewCell*)cell;

    NSDictionary *entity = config.whitelist[indexPath.item];
    whitelistCell.nicknameLabel.text = entity[@"nickname"];
    whitelistCell.publicIdLabel.text = entity[@"publicId"];

    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        deletedEntity = config.whitelist[indexPath.item];
        deletedIndex = indexPath;
        NSString *publicId = deletedEntity[@"publicId"];
        [_contactManager setResponseConsumer:self];
        [_contactManager setViewController:self];
        [_contactManager deleteFriend:publicId];
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

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
    NSString *nickname = view.nicknameTextField.text;
    NSString *publicId = view.publicIdTextField.text;
    NSMutableDictionary *entity = [NSMutableDictionary dictionaryWithObjectsAndKeys:nickname, @"nickname", publicId, @"publicId", nil];
    [config addWhitelistEntry:entity];
    [self.view setNeedsDisplay];

}

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
