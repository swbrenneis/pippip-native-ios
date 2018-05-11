//
//  MessagesHeadingCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework

class MessagesHeadingCell: UITableViewCell {

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

    @objc func configure(backgroundColor: UIColor) {

        self.backgroundColor = .clear
        contentView.backgroundColor = backgroundColor
        contentView.layer.cornerRadius = 15
        contentView.layer.masksToBounds = true
        messageSearchTextField.backgroundColor = backgroundColor
        messageSearchTextField.textColor = ContrastColorOf(backgroundColor, returnFlat: true)
        messagesLabel.textColor = ContrastColorOf(backgroundColor, returnFlat: true)

    }

}
