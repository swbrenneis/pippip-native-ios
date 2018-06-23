//
//  ContactDetailCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/26/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ContactDetailCell: PippipTableViewCell {

    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var publicIdLabel: UILabel!
    @IBOutlet weak var lastSeenLabel: UILabel!
    @IBOutlet weak var resendRequestButton: UIButton!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var lastSeenTitle: UILabel!

    var contactManager = ContactManager()
    var publicId: String!
    var alertPresenter = AlertPresenter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(contact: Contact, expanded: Bool) {

        publicId = contact.publicId
        displayNameLabel.text = contact.displayName
        statusImageView.image = UIImage(named: contact.status)
        if expanded {
            publicIdLabel.text = contact.publicId
            setLastSeen(timestamp: contact.timestamp)
            lastSeenLabel.isHidden = false
            lastSeenTitle.isHidden = false
            resendRequestButton.isHidden = contact.status != "pending"
        }
        else {
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
        publicIdLabel.textColor = PippipTheme.darkTextColor
        lastSeenLabel.textColor = PippipTheme.darkTextColor
        resendRequestButton.setTitleColor(PippipTheme.buttonDarkTextColor, for: .normal)

    }
    
    override func setMediumTheme() {
        super.setMediumTheme()
        

        displayNameLabel.textColor = PippipTheme.mediumTextColor
        publicIdLabel.textColor = PippipTheme.mediumTextColor
        lastSeenLabel.textColor = PippipTheme.mediumTextColor
        resendRequestButton.setTitleColor(PippipTheme.buttonMediumTextColor, for: .normal)
        
    }
    
    override func setLightTheme() {
        super.setLightTheme()
        

        displayNameLabel.textColor = PippipTheme.lightTextColor
        publicIdLabel.textColor = PippipTheme.lightTextColor
        lastSeenLabel.textColor = PippipTheme.lightTextColor
        resendRequestButton.setTitleColor(PippipTheme.buttonLightTextColor, for: .normal)
        
    }
    
    @IBAction func resendRequest(_ sender: Any) {

        contactManager.requestContact(publicId: publicId, nickname: nil, retry: true)
        alertPresenter.infoAlert(title: "Contact Request Sent", message: "The request was sent to this contact")

    }

}
