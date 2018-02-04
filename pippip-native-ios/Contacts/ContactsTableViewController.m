//
//  ContactsTableViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/9/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "ContactsTableViewController.h"
#import "AppDelegate.h"
#import "ContactManager.h"
#import "AddContactViewController.h"
#import "ContactDetailViewController.h"
#import "ContactTableViewCell.h"

@interface ContactsTableViewController ()
{
    NSDictionary *addedContact;
}

@property (weak, nonatomic) ContactManager *contactManager;

@end

@implementation ContactsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void)viewWillAppear:(BOOL)animated {

    // Get the contact manager
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _contactManager = delegate.accountSession.contactManager;
    
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)response:(NSDictionary *)info {

    NSArray *contacts = info[@"contacts"];
    NSMutableArray *synched = [NSMutableArray array];
    for (NSDictionary *entity in contacts) {
        NSMutableDictionary *localContact = [_contactManager getContact:entity[@"publicId"]];
        if (localContact != nil) {
            localContact[@"status"] = entity[@"status"];
            localContact[@"currentIndex"] = entity[@"currentIndex"];
            localContact[@"currentSequence"] = entity[@"currentSequence"];
            localContact[@"timestamp"] = entity[@"timestamp"];
            [synched addObject:localContact];
        }
        else {
            [synched addObject:[entity mutableCopy]];
        }
    }
    [_contactManager setContacts:synched];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });

}

- (IBAction)syncContacts:(id)sender {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Caution!"
                                                                   message:@"Synchronizing contacts with the server may result in deletion of some local contacts"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         [_contactManager setViewController:self];
                                                         [_contactManager setResponseConsumer:self];
                                                         [_contactManager syncContacts];
                                                     }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];

}

- (IBAction)unwindAfterRequestAdded:(UIStoryboardSegue*)segue {

    AddContactViewController *view = (AddContactViewController*)segue.sourceViewController;
    [_contactManager addLocalContact:view.addedContact];
    [self.view setNeedsDisplay];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_contactManager contactCount];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
    
    NSDictionary *entity = [_contactManager contactAtIndex:indexPath.item];
    if (entity != nil) {
        NSString *nickname = entity[@"nickname"];
        NSString *publicId = entity[@"publicId"];
        NSString *status = entity[@"status"];

        ContactTableViewCell *contactCell = (ContactTableViewCell*)cell;
        if (nickname != nil) {
            contactCell.nicknameLabel.text = nickname;
        }
        else {
            contactCell.nicknameLabel.text = @"";
        }
        contactCell.publicIdLabel.text = publicId;
        contactCell.statusImageView.image = [UIImage imageNamed:status];
    }
    else {
        NSLog(@"Contact index %ld out of range", (long)indexPath.item);
    }

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

- (IBAction) unwindToContactsViewController:(UIStoryboardSegue*)segue {
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    UIViewController *view = [segue destinationViewController];
    if ([view isKindOfClass:[ContactDetailViewController class]]) {
        ContactDetailViewController *detailView = (ContactDetailViewController*)view;
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        detailView.contact = [_contactManager contactAtIndex:selectedIndexPath.item];
    }
}

@end
