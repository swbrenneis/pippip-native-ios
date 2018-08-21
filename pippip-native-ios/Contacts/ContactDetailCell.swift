//
//  ContactDetailCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/26/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ContactDetailCell: PippipTableViewCell, UITextFieldDelegate {

    @IBOutlet weak var publicIdLabel: UILabel!
    @IBOutlet weak var lastSeenLabel: UILabel!
    @IBOutlet weak var resendRequestButton: UIButton!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var lastSeenTitle: UILabel!
    @IBOutlet weak var displayNameText: UITextField!
    @IBOutlet weak var displayNameLabel: UILabel!
    
    var contactManager = ContactManager()
    var publicId: String!
    var alertPresenter = AlertPresenter()
    var contact: Contact!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        displayNameText.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(contact: Contact, expanded: Bool) {

        self.contact = contact
        publicId = contact.publicId
        displayNameText.text = contact.directoryId
        displayNameLabel.text = contact.displayName
        statusImageView.image = UIImage(named: contact.status)
        resendRequestButton.backgroundColor = PippipTheme.buttonColor
        resendRequestButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        self.backgroundColor = .clear
        if expanded {
            displayNameText.isHidden = false
            displayNameLabel.isHidden = true
            publicIdLabel.text = contact.publicId
            publicIdLabel.isHidden = false
            setLastSeen(timestamp: contact.timestamp)
            lastSeenLabel.isHidden = false
            lastSeenTitle.isHidden = false
            resendRequestButton.isHidden = contact.status != "pending"
        }
        else {
            displayNameText.isHidden = true
            displayNameLabel.isHidden = false
            publicIdLabel.isHidden = true
            lastSeenLabel.isHidden = true
            resendRequestButton.isHidden = true
            lastSeenTitle.isHidden = true
        }

    }

    func setLastSeen(timestamp: Int64) {
        
        let lastSeenFormatter = DateFormatter()
        lastSeenFormatter.dateFormat = "MMM dd YYYY hh:mm"
        if (timestamp == 0) {
            lastSeenLabel.text = "Never"
        }
        else {
            let tsDate = Date.init(timeIntervalSince1970: TimeInterval(timestamp))
            lastSeenLabel.text = lastSeenFormatter.string(from: tsDate)
        }
        
    }

    override func setDarkTheme() {
        super.setDarkTheme()

        displayNameLabel.textColor = PippipTheme.darkTextColor
        displayNameText.textColor = PippipTheme.darkTextColor
        publicIdLabel.textColor = PippipTheme.darkTextColor
        lastSeenLabel.textColor = PippipTheme.darkTextColor
        resendRequestButton.setTitleColor(PippipTheme.buttonDarkTextColor, for: .normal)

    }
    
    override func setMediumTheme() {
        super.setMediumTheme()
        
        displayNameLabel.textColor = PippipTheme.mediumTextColor
        displayNameText.textColor = PippipTheme.mediumTextColor
        publicIdLabel.textColor = PippipTheme.mediumTextColor
        lastSeenLabel.textColor = PippipTheme.mediumTextColor
        resendRequestButton.setTitleColor(PippipTheme.buttonMediumTextColor, for: .normal)
        
    }
    
    override func setLightTheme() {
        super.setLightTheme()
        
        displayNameLabel.textColor = PippipTheme.lightTextColor
        displayNameText.textColor = PippipTheme.lightTextColor
        publicIdLabel.textColor = PippipTheme.lightTextColor
        lastSeenLabel.textColor = PippipTheme.lightTextColor
        resendRequestButton.setTitleColor(PippipTheme.buttonLightTextColor, for: .normal)
        
    }
    
    @IBAction func resendRequest(_ sender: Any) {

        contactManager.requestContact(publicId: publicId, directoryId: nil, retry: true)
        alertPresenter.infoAlert(title: "Contact Request Sent", message: "The request was sent to this contact")

    }

    // Text field delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField.text != contact.directoryId {
            let contactManager = ContactManager()
            contactManager.setDirectoryId(contactId: contact.contactId, directoryId: textField.text)
            contact.directoryId = textField.text
            displayNameLabel.text = contact.displayName
        }
        textField.resignFirstResponder()
        return true

    }

}
