//
//  PendingContactViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "PendingContactViewController.h"
#import "ContactManager.h"
#import "ContactDatabase.h"
//#import "NSData+HexEncode.h"
#import "AlertErrorDelegate.h"

@interface PendingContactViewController ()
{
    ContactDatabase *contactDatabase;
    ContactManager *contactManager;
}

@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *publicIdLabel;

@end

@implementation PendingContactViewController

@synthesize errorDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:self withTitle:@"Contact Error"];

}

- (void)viewWillAppear:(BOOL)animated {

    contactManager = [[ContactManager alloc] init];
    //[contactManager setResponseConsumer:self];
    contactDatabase = [[ContactDatabase alloc] init];
    
    if (_requestNickname != nil) {
        _nicknameLabel.text = _requestNickname;
    }
    else {
        _nicknameLabel.text = @"No Nickname";
    }
    _publicIdLabel.text = _requestPublicId;

}

- (IBAction)cancelClicked:(UIBarButtonItem *)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)response:(NSDictionary *)info {

    NSDictionary *contact = info[@"acknowledged"];
    NSString *publicId = contact[@"publicId"];
    NSString *status = contact[@"status"];
    NSString *authData = contact[@"authData"];
    NSString *nonce = contact[@"nonce"];
    NSArray *keyStrings = contact[@"messageKeys"];
    if (publicId == nil || status == nil || authData == nil || keyStrings == nil || nonce == nil) {
        [self errorAlert:@"Invalid server response"];
    }
    else {
        if ([status isEqualToString:@"accepted"]) {
        }
    }

}
/*
- (IBAction)acceptRequest:(id)sender {

    [contactManager acknowledgeRequest:@"accept" withId:_publicIdLabel.text];
    
}

- (IBAction)rejectRequest:(id)sender {

    [contactManager acknowledgeRequest:@"reject" withId:_publicIdLabel.text];
    
}

- (IBAction)ignoreRequest:(id)sender {

    [contactManager acknowledgeRequest:@"ignore" withId:_publicIdLabel.text];
    
}
*/
- (void)contactAddedAlert {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Contact Added"
                                                                   message:@"This ID has been added to your contacts"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler: ^(UIAlertAction *action) {
                                                         [self performSegueWithIdentifier:@"UnwindAfterAdd"
                                                                                   sender:self];
                                                     }];
    [alert addAction:okAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
    
}

- (NSArray*)decodeKeys:(NSArray*)keyStrings {

    NSMutableArray *keys = [NSMutableArray array];
    for (NSString *key in keyStrings) {
        [keys addObject:[[NSData alloc] initWithBase64EncodedString:key options:0]];
    }
    return keys;

}

- (void)errorAlert:(NSString*)message {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Contact Error"
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
