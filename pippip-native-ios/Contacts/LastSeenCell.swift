//
//  LastSeenCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/26/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class LastSeenCell: UITableViewCell {

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

}
