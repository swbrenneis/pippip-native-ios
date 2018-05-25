//
//  PublicIdCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/26/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ContactPublicIdCell: ExpandingTableCell {

    @IBOutlet weak var publicIdLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func configure() {

        setLightTheme()
        super.configure()

    }

    override func setDarkTheme() {
        
        publicIdLabel.textColor = PippipTheme.darkTextColor
        super.setDarkTheme()
        
    }
    
    override func setMediumTheme() {
        
        publicIdLabel.textColor = PippipTheme.mediumTextColor
        super.setMediumTheme()
        
    }
    
    override func setLightTheme() {
        
        publicIdLabel.textColor = PippipTheme.lightTextColor
        super.setLightTheme()
        
    }
    
}
