//
//  PublicIdCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/22/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

@objc class PublicIdCell: UITableViewCell {

    @IBOutlet weak var publicIdLabel: UILabel!

    override public var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }

    @objc class func cellItem() -> MoreCellItem {

        let item: MoreCellItem = MoreCellItem()
        item.cellHeight = 65.0
        item.cellReuseId = "PublicIdCell"
        return item

    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        publicIdLabel.text = ApplicationSingleton.instance().accountSession.sessionState.publicId
        attachTapHandler()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

     func attachTapHandler() {

        let tapped: UIGestureRecognizer = UILongPressGestureRecognizer(target: self,
                                                                       action: #selector(handleTap))
        addGestureRecognizer(tapped)
        
    }

    @objc func handleTap(gesture:UIGestureRecognizer) {

        becomeFirstResponder()
        let menu = UIMenuController.shared
        menu.setTargetRect(self.frame, in:self.superview!)
        menu.setMenuVisible(true, animated:true)

    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {

        return action == #selector(copy(_:))

    }

    override func copy(_ sender: Any?) {

        let paste = UIPasteboard.general
        paste.string = publicIdLabel.text

    }

}
