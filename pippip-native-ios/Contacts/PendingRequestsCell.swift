//
//  PendingRequestsCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 8/20/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class PendingRequestsCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.backgroundColor = PippipTheme.lightBarColor
        titleLabel.backgroundColor = PippipTheme.buttonColor
        titleLabel.textColor = PippipTheme.buttonTextColor
        titleLabel.layer.masksToBounds = true
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
