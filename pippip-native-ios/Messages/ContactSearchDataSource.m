//
//  ContactSearchDataSource.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/5/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ContactSearchDataSource.h"

@interface ContactSearchDataSource ()
{
    NSArray *contactList;
}
@end

@implementation ContactSearchDataSource

- (void) setContactList:(NSArray *)contacts {

    contactList = contacts;
    if (contacts == nil) {
        _rowsInTable = 0;
    }
    else {
        _rowsInTable = contacts.count;
    }
    [_tableView reloadData];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _rowsInTable;

}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewMessageContactCell"];

    NSDictionary *contact = contactList[indexPath.item];
    NSString *nickname = contact[@"nickname"];
    NSString *publicId = contact[@"publicId"];
    if (nickname == nil) {
        cell.textLabel.text = publicId;
    }
    else {
        cell.textLabel.text = nickname;
        cell.detailTextLabel.text = publicId;
    }
    [cell setHidden:NO];

    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSDictionary *contact = contactList[indexPath.item];
    [_messageSource contactSelected:contact[@"publicId"] withNickname:contact[@"nickname"]];

}

@end
