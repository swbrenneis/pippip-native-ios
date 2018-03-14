//
//  RequestsViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/28/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "RequestsViewController.h"
#import "ContactManager.h"
#import "RequestsTableViewCell.h"
#import "PendingContactViewController.h"
#import "AlertErrorDelegate.h"

@interface RequestsViewController ()
{
    NSArray *requests;
    NSInteger selectedRow;
    ContactManager *contactManager;
    UIActivityIndicatorView *activityIndicator;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation RequestsViewController

@synthesize errorDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    contactManager = [[ContactManager alloc] init];
    [contactManager setResponseConsumer:self];
    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:self withTitle:@"Contact Request Error"];
    [_tableView setDelegate:self];
    _tableView.dataSource = self;

    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:activityIndicator];
    activityIndicator.center = self.view.center;

}

-(void)viewDidAppear:(BOOL)animated {

    [activityIndicator startAnimating];
    [contactManager getRequests];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneClicked:(UIBarButtonItem *)sender {

    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)response:(NSDictionary *)info {
    
    requests = info[@"requests"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [activityIndicator stopAnimating];
        if (requests.count > 0) {
            _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        }
        else {
            _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        [_tableView reloadData];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 75.0;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    selectedRow = indexPath.item;
    [self performSegueWithIdentifier:@"PendingContactSegue" sender:self];
    
}

#pragma mark - Navigation

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
