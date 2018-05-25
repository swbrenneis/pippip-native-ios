//
//  ExpandingTableViewCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework

class ExpandingTableViewCell: ExpandingTableCell {

    var isOpen: Bool {
        return openFlag
    }
    var openCloseLabel: UILabel!
    var children: [ExpandingTableCell]?
    private var openFlag = false

    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        initialize()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = self.bounds.width
        let height = self.bounds.height
        
        openCloseLabel.frame = CGRect(x: width - 40, y: (height - 12)/2, width: 12, height: 12)
        
    }

    func initialize() {

        openCloseLabel = UILabel()
        openCloseLabel.font = UIFont(name: "Arial-BoldMT", size: 21)
        openCloseLabel.text = "+"
        self.contentView.addSubview(openCloseLabel)
        self.selectionStyle = .none

    }

    override func setDarkTheme() {
        
        openCloseLabel.textColor = PippipTheme.darkTextColor
        super.setDarkTheme()

    }
    
    override func setMediumTheme() {
        
        openCloseLabel.textColor = PippipTheme.mediumTextColor
        super.setMediumTheme()

    }
    
    override func setLightTheme() {
        
        openCloseLabel.textColor = PippipTheme.lightTextColor
        super.setLightTheme()

    }
    
    func open() {

        if !openFlag {
            openCloseLabel.text = "-"
            openFlag = true
        }

    }

    func close() {

        if openFlag {
            openCloseLabel.text = "+"
            openFlag = false
        }
        
    }

}
