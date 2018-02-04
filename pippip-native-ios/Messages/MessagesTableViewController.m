//
//  MessagesTableViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/9/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "MessagesTableViewController.h"
#import "AppDelegate.h"
#import "MessageManager.h"
#import "PreviewTableViewCell.h"

@interface MessagesTableViewController ()
{
    NSArray *mostRecent;
}

@property (weak, nonatomic) MessageManager *messageManager;

@end

@implementation MessagesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {

    // Get the message manager
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _messageManager = delegate.accountSession.messageManager;
    mostRecent = [_messageManager getMostRecentMessages];
    
    [self.tableView reloadData];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSInteger count = mostRecent.count;
    if (count > 0) {
        return count;
    }
    else {
        return 1;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PreviewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    PreviewTableViewCell *previewCell = (PreviewTableViewCell*)cell;
    NSDictionary *message = mostRecent[indexPath.item];
    NSNumber *read = message[@"read"];
    [previewCell.messageReadImage setHidden:[read boolValue]];
    NSString *sender = message[@"sender"];
    if (sender.length > 14) {
        NSString *shortened = [sender substringWithRange:NSMakeRange(0, 14)];
        previewCell.senderLabel.text = [shortened stringByAppendingString:@"..."];
    }
    else {
        previewCell.senderLabel.text = sender;
    }
    NSString *dt = message[@"dateTime"];
    previewCell.dateTimeLabel.text = [dt stringByAppendingString:@" >"];
    NSString *msgText = message[@"message"];
    if (msgText.length > 33) {
        NSString *preview = [msgText substringWithRange:NSMakeRange(0, 33)];
        previewCell.previewLabel.text = [preview stringByAppendingString:@"..."];
    }
    else {
        previewCell.previewLabel.text = msgText;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
