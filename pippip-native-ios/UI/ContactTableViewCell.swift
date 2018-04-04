//
//  ContactTableViewCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/4/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    var cellView: ContactCellView?
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
        cellView = ContactCellView(frame: self.bounds)
        self.addSubview(cellView!)
        
    }
    
}
