//
//  ContactTableViewCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/4/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var nibView: UIView!
    @IBOutlet weak var publicIdLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!

    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = .clear
        nibView.backgroundColor = .clear
        self.selectionStyle = .none

    }

}
