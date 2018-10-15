//
//  ContactCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ContactCell: PippipTableViewCell {

    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(contact: Contact) {
        
        displayNameLabel.text = contact.displayName
        statusImageView.image = UIImage(named: contact.status)

    }

}
