//
//  AddContactViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/12/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "AddContactViewController.h"
#import "ContactsTableViewController.h"
#import "ContactEntity.h"

@interface AddContactViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nicknameText;
@property (weak, nonatomic) IBOutlet UITextField *publicIdText;

@end

@implementation AddContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    ContactsTableViewController *viewController = (ContactsTableViewController*)[segue destinationViewController];
    ContactEntity *entity = [[ContactEntity alloc] initWithPublicId:_publicIdText.text
                                                       withNickname:_nicknameText.text];
    [viewController addContact:entity];

}


@end
