//
//  ContactCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/25/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ContactCell: ExpandingTableViewCell {

    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var identLabel: UILabel!

    static let cellHeight: CGFloat = 63.0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
