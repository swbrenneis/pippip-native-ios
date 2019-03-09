//
//  Strings.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/6/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import Foundation

struct Strings {
    
    // Error strings
    static let errorRequestFailed = "The request could not be completed, please try again"
    static let errorAuthenticationFailed = "Authentication failure, please try again"
    static let errorInvalidResponse = "The server sent an invalid response"
    static let errorInternal = "An application error occured, please try again"
    static let errorDuplicateContact = "This contact is already in your contact list"
    static let errorDuplicateRequest = "There is a pending request for that contact on the server"
    static let errorIdNotFound = "That directory ID does not exist"
    
    // Success strings
    static let successRequestResent = "The request has been sent"
    
    // General UI strings
    static let addContactTitle = "Add A New Contact"
    static let addContactErrorTitle = "Add Contact Error"
    static let addContactButtonTitle = "Add"
    static let initialmessagePrompt = "If you wish, enter an initial message to this contact here"
    
}
