//
//  AddContactTableViewCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/13/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import UIKit

class AddContactTableViewCell: UITableViewCell {

    @IBOutlet weak var addContactLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        addContactLabel.backgroundColor = PippipTheme.lightBarColor
        addContactLabel.textColor = UIColor.flatTealDark
        addContactLabel.layer.cornerRadius = 7.0
        addContactLabel.layer.masksToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
