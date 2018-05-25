//
//  PendingContactCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class PendingRequestCell: ExpandingTableCell {

    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var publicIdLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func setLightTheme() {
        
        nicknameLabel.textColor = PippipTheme.lightTextColor
        super.setLightTheme()
        
    }
    
    override func setMediumTheme() {
        
        nicknameLabel.textColor = PippipTheme.mediumTextColor
        super.setMediumTheme()
        
    }
    
    override func setDarkTheme() {
        
        nicknameLabel.textColor = PippipTheme.darkTextColor
        super.setDarkTheme()
        
    }
    
}
