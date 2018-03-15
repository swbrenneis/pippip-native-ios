//
//  ContactsTableViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/9/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "ContactsTableViewController.h"
#import "ApplicationSingleton.h"
#import "ContactManager.h"
#import "ContactDatabase.h"
#import "AddContactViewController.h"
#import "ContactDetailViewController.h"
#import "ContactTableViewCell.h"
#import "AlertErrorDelegate.h"

@interface ContactsTableViewController ()
{
    NSDictionary *addedContact;
    ContactDatabase *contactDatabase;
    NSArray *contactList;
    ContactManager *contactManager;
}


@end

@implementation ContactsTableViewController

@synthesize errorDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    contactManager = [[ContactManager alloc] init];
    [contactManager setResponseConsumer:self];
    contactDatabase = [[ContactDatabase alloc] init];

    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:self withTitle:@"Contact List Error"];

}

- (void)viewWillAppear:(BOOL)animated {

    contactList = [contactDatabase getContactList];

    [self.tableView reloadData];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contactsUpdated:)
                                                 name:@"ContactsUpdated" object:nil];

}

- (void)viewWillDisappear:(BOOL)animated {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ContactsUpdated" object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)contactsUpdated:(NSNotification*)notification {

    contactList = [contactDatabase getContactList];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.tableView reloadData];
    });

}

- (void)response:(NSDictionary *)info {

    NSString *result = info[@"result"];
    NSString *prefix = @"Contact synchronization ";
    NSString *message;
    if ([result isEqualToString:@"contacts set"]) {
        message = [prefix stringByAppendingString:@"successful"];
    }
    else {
        NSLog(@"Contact sync server response: %@", result);
        message = [prefix stringByAppendingString:@"failed"];
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Synchronize Contacts"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });

}

- (void)contactsUpdated {

    contactList = [contactDatabase getContactList];
    [self.tableView reloadData];

}

- (IBAction)syncContacts:(id)sender {

    [contactManager syncContacts];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return contactList.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
    
    NSDictionary *entity = contactList[indexPath.item];
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
        detailView.contact = contactList[selectedIndexPath.item];
    }
}

@end
