//
//  ContactCellView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/30/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ContactCellView: UIView {

    @IBOutlet var contentView: ContactCellView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var publicIdLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //commonInit()
    }

    func commonInit() {

        Bundle.main.loadNibNamed("ContactCellView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]

    }

}
