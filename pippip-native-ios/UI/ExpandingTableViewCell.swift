//
//  ExpandingTableViewCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ExpandingTableViewCell: UITableViewCell {

    private var isOpen = false
    open var openCloseImage: UIImageView!

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
        
        openCloseImage.frame = CGRect(x: width - 40, y: (height - 12)/2, width: 12, height: 12)

    }
    
    func initialize() {

        isOpen = false
        openCloseImage  = UIImageView()
        openCloseImage.image = UIImage(named: "to-expand")
        self.contentView.addSubview(openCloseImage)
        self.selectionStyle = .none

    }

    func open() {

        if !isOpen {
            openCloseImage.image = UIImage(named: "to-collapse")
            isOpen = true
        }

    }

    func close() {

        if isOpen {
            openCloseImage.image = UIImage(named: "to-expand")
            isOpen = false
        }
        
    }

    open func isExpanded() -> Bool {
        return isOpen
    }

}
