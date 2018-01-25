//
//  PendingContactViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "PendingContactViewController.h"
#import "AppDelegate.h"
#import "ContactManager.h"
#import "NSData+HexEncode.h"

@interface PendingContactViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *publicIdLabel;

@property (weak, nonatomic) ContactManager *contactManager;

@end

@implementation PendingContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // Get the contact manager
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _contactManager = delegate.contactManager;
    
}

- (void)viewWillAppear:(BOOL)animated {

    if (_requestNickname != nil) {
        _nicknameLabel.text = _requestNickname;
    }
    else {
        _nicknameLabel.text = @"No Nickname";
    }
    _publicIdLabel.text = _requestPublicId;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)response:(NSDictionary *)info {

    NSString *publicId = info[@"id"];
    NSString *response = info[@"response"];
    NSString *authData = info[@"authData"];
    NSArray *keyStrings = info[@"keys"];
    if (publicId == nil || response == nil || authData == nil || keyStrings == nil) {
        [self errorAlert:@"Invalid server response"];
    }
    else {
        if ([response isEqualToString:@"accepted"]) {
            NSMutableDictionary *entity = [NSMutableDictionary dictionary];
            entity[@"publicId"] = publicId;
            if (_requestNickname != nil) {
                entity[@"nickname"] = _requestNickname;
            }
            entity[@"currentIndex"] = [NSNumber numberWithLongLong:0];
            entity[@"currentSequence"] = [NSNumber numberWithLongLong:0];
            entity[@"timestamp"] = info[@"timestamp"];
            entity[@"status"] = response;
            NSError *error = nil;
            NSData *adBytes = [NSData dataWithHexString:authData withError:&error];
            if (error == nil) {
                entity[@"authData"] = adBytes;
                NSArray *keys = [self decodeKeys:keyStrings];
                if (keys != nil) {
                    entity[@"messageKeys"] = keys;
                    [_contactManager addContact:entity];
                    [self contactAddedAlert];
                }
            }
            else {
                [self errorAlert:@"Encoding error"];
            }
        }
    }

}

- (IBAction)acceptRequest:(id)sender {

    [_contactManager setViewController:self];
    [_contactManager setResponseConsumer:self];
    [_contactManager acknowledgeRequest:@"accept" withId:_publicIdLabel.text];
    
}

- (IBAction)rejectRequest:(id)sender {

    [_contactManager setViewController:self];
    [_contactManager setResponseConsumer:self];
    [_contactManager acknowledgeRequest:@"reject" withId:_publicIdLabel.text];
    
}

- (IBAction)ignoreRequest:(id)sender {

    [_contactManager setViewController:self];
    [_contactManager setResponseConsumer:self];
    [_contactManager acknowledgeRequest:@"ignore" withId:_publicIdLabel.text];
    
}

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
    NSError *error = nil;
    for (NSString *key in keyStrings) {
        [keys addObject:[NSData dataWithHexString:key withError:&error]];
        if (error != nil) {
            return nil;
        }
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