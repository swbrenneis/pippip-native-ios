//
//  WhitelistViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/23/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "WhitelistViewController.h"
#import "ApplicationSingleton.h"
#import "AddFriendCell.h"
#import "ContactManager.h"
#import "AlertErrorDelegate.h"

@interface WhitelistViewController ()
{
    NSDictionary *deletedEntity;
    NSIndexPath *deletedIndex;
    NSString *accountName;
    ContactManager *contactManager;
    BOOL addingFriend;
    NSString *method;
    NSString *newNickname;
    NSString *newPublicId;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) Configurator *config;

@end

@implementation WhitelistViewController

@synthesize errorDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _tableView.dataSource = self;
    [_tableView setDelegate:self];
    _config = [ApplicationSingleton instance].config;
    contactManager = [[ContactManager alloc] init];
    [contactManager setResponseConsumer:self];
    addingFriend = NO;

    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:self withTitle:@"Friends List Error"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    ApplicationSingleton *app = [ApplicationSingleton instance];
    accountName = app.accountSession.sessionState.currentAccount;
    [_config loadWhitelist];
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) response:(NSDictionary *)info {

    if (info != nil) {
        if ([method isEqualToString:@"DeleteFriend"]) {
            NSString *result = info[@"result"];
            if ([result isEqualToString:@"not found"]) {
                NSString *publicId = deletedEntity[@"publicId"];
                NSLog(@"Friend %@ not found on server", publicId);
            }
            [_config deleteWhitelistEntry:deletedEntity[@"publicId"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        }
        else if ([method isEqualToString:@"MatchNickname"]) {
            [self matchNicknameComplete:info];
        }
        else {
            NSString *result = info[@"result"];
            if ([result isEqualToString:@"added"]) {
                addingFriend = NO;
                NSMutableDictionary *entity =
                        [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                newNickname, @"nickname", newPublicId, @"publicId", nil];
                [_config addWhitelistEntry:entity];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                });
            }
            else if ([result isEqualToString:@"exists"]) {
                [errorDelegate responseError:@"This friend is already in your friends list"];
            }
            else {
                [errorDelegate responseError:@"Invalid response from server"];
            }
        }
    }
    
}

- (void)addFriend:(NSString *)nickname withPublicId:(NSString *)publicId {

    newNickname = nickname;
    newPublicId = publicId;
    if (nickname.length != 0) {
        method = @"MatchNickname";
        [contactManager matchNickname:nickname withPublicId:nil];
    }
    else if (publicId.length != 0) {
        method = @"UpdateWhitelist";
        [contactManager addFriend:publicId];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Friend ID"
                                                                       message:@"Please provide nickname or public ID"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }

}

- (void)cancelAddFriend {

    addingFriend = NO;
    [_tableView reloadData];

}

- (void)matchNicknameComplete:(NSDictionary*)response {
    
    NSString *result = response[@"result"];
    if ([result isEqualToString:@"found"]) {
        method = @"UpdateWhitelist";
        newPublicId = response[@"publicId"];
        [contactManager addFriend:newPublicId];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Friend ID"
                                                                       message:@"Invalid nickname"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alert addAction:okAction];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
    
}

- (IBAction)addFriend:(UIBarButtonItem *)sender {

    addingFriend = YES;
    [_tableView reloadData];

}

- (IBAction)donePressed:(UIBarButtonItem *)sender {

    [self dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (addingFriend) {
        return _config.whitelist.count + 1;
    }
    else {
        return _config.whitelist.count;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (addingFriend && indexPath.item == _config.whitelist.count) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddFriendCell" forIndexPath:indexPath];
        AddFriendCell *addFriend = (AddFriendCell*)cell;
        [addFriend setViewController:self];
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WhitelistCell" forIndexPath:indexPath];
        NSDictionary *entity = _config.whitelist[indexPath.item];
        cell.textLabel.text = entity[@"nickname"];
        cell.detailTextLabel.text = entity[@"publicId"];
        
        return cell;
    }
    
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.

    if (addingFriend && indexPath.item == _config.whitelist.count) {
        return NO;
    }
    else {
        return YES;
    }
    
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        deletedEntity = _config.whitelist[indexPath.item];
        deletedIndex = indexPath;
        NSString *publicId = deletedEntity[@"publicId"];
        [contactManager deleteFriend:publicId];
        method = @"DeleteFriend";
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (addingFriend && indexPath.item == _config.whitelist.count) {
        return 86.0;
    }
    else {
        return 75.0;
    }

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
