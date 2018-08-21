//
//  PendingContactCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class PendingRequestCell: PippipTableViewCell {

    @IBOutlet weak var directoryIdLabel: UILabel!
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
        
        directoryIdLabel.textColor = PippipTheme.lightTextColor
        publicIdLabel.textColor = PippipTheme.lightTextColor
        super.setLightTheme()
        
    }
    
    override func setMediumTheme() {
        
        directoryIdLabel.textColor = PippipTheme.mediumTextColor
        publicIdLabel.textColor = PippipTheme.mediumTextColor
        super.setMediumTheme()
        
    }
    
    override func setDarkTheme() {
        
        directoryIdLabel.textColor = PippipTheme.darkTextColor
        publicIdLabel.textColor = PippipTheme.darkTextColor
        super.setDarkTheme()
        
    }
    
}
