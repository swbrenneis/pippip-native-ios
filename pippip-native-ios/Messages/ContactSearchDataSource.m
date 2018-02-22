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
    NSInteger rowsInTable;
    NSArray *contactList;
}
@end

@implementation ContactSearchDataSource

- (void) setContactList:(NSArray *)contacts {

    contactList = contacts;
    if (contacts == nil) {
        rowsInTable = 0;
    }
    else {
        rowsInTable = contacts.count;
    }

}

- (NSDictionary*)contactAtRow:(NSInteger)row {
    return contactList[row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return rowsInTable;

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

@end
