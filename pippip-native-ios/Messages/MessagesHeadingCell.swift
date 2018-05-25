//
//  MessagesHeadingCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework

class MessagesHeadingCell: PippipTableViewCell {

    @IBOutlet weak var messageSearchTextField: UITextField!
    @IBOutlet weak var messagesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @objc func configure() {

        messageSearchTextField.backgroundColor = PippipTheme.mediumCellColor
        messageSearchTextField.textColor = PippipTheme.mediumTextColor
        messagesLabel.textColor = PippipTheme.mediumTextColor

        super.setMediumTheme()

    }

}
