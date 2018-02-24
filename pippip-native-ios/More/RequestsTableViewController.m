//
//  RequestsTableViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/10/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "RequestsTableViewController.h"
#import "AppDelegate.h"
#import "ContactManager.h"
#import "RequestsTableViewCell.h"
#import "PendingContactViewController.h"
#import "AlertErrorDelegate.h"

@interface RequestsTableViewController ()
{
    NSArray *requests;
    NSInteger selectedRow;
    ContactManager *contactManager;
}


@end

@implementation RequestsTableViewController

@synthesize errorDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    contactManager = [[ContactManager alloc] init];
    [contactManager setResponseConsumer:self];
    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:self withTitle:@"Contact Request Error"];

}

-(void)viewWillAppear:(BOOL)animated {

    [contactManager getRequests];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)response:(NSDictionary *)info {

    requests = info[@"requests"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (requests.count > 0) {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        }
        else {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        [self.tableView reloadData];
    });

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (requests == nil || requests.count == 0) {
        return 1;
    }
    else {
        return requests.count;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RequestCell" forIndexPath:indexPath];
    RequestsTableViewCell *requestsCell = (RequestsTableViewCell*)cell;

    if (requests == nil || requests.count == 0) {
        requestsCell.nicknameLabel.text = @"No Requests";
        requestsCell.publicIdLabel.text = @"";
    }
    else {
        NSDictionary *entity = requests[indexPath.item];
        NSString *nickname = entity[@"nickname"];
        if (nickname != nil) {
            requestsCell.nicknameLabel.text = nickname;
        }
        requestsCell.publicIdLabel.text = entity[@"publicId"];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (requests == nil || requests.count == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        selectedRow = indexPath.item;
        [self performSegueWithIdentifier:@"PendingContactSegue" sender:self];
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

#pragma mark - Navigation

- (IBAction)unwindToRequestTable:(UIStoryboardSegue*)segue {

}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *controller = segue.destinationViewController;
    if ([controller isKindOfClass:[PendingContactViewController class]]) {
        PendingContactViewController *pending = (PendingContactViewController*)segue.destinationViewController;
        NSDictionary *entity = requests[selectedRow];
        pending.requestNickname = entity[@"nickname"];
        pending.requestPublicId = entity[@"publicId"];
    }

}


@end
