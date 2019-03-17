//
//  NewRequestsTableViewCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/13/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import UIKit

class NewRequestsTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.textLabel?.textColor = PippipTheme.titleColor

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
