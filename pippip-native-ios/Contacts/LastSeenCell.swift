//
//  LastSeenCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/26/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class LastSeenCell: ExpandingTableCell {

    @IBOutlet weak var lastSeenLabel: UILabel!

    static let cellHeight: CGFloat = 45.0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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

    override func configure() {

        setLightTheme()
        super.configure()

    }

    override func setDarkTheme() {
        
        lastSeenLabel.textColor = PippipTheme.darkTextColor
        super.setDarkTheme()
        
    }
    
    override func setMediumTheme() {

        lastSeenLabel.textColor = PippipTheme.mediumTextColor
        super.setMediumTheme()
        
    }
    
    override func setLightTheme() {
        
        lastSeenLabel.textColor = PippipTheme.lightTextColor
        super.setLightTheme()
        
    }
    
}
