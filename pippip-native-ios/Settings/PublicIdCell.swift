//
//  PublicIdCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/22/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class PublicIdCellItem: MultiCellItemProtocol {

    var cellReuseId: String = "PublicIdCell"
    var cellHeight: CGFloat = 65.0
    var currentCell: PippipTableViewCell?

}

class PublicIdCell: PippipTableViewCell, MultiCellProtocol {

    @IBOutlet weak var publicIdLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    static var cellItem: MultiCellItemProtocol = PublicIdCellItem()
    var viewController: UITableViewController?
    var sessionState = SessionState.instance

    override public var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func configure() {

        publicIdLabel.text = sessionState.publicId
        attachTapHandler()
        
    }
    
    // Reset to configuration default
    override func reset() {
        
        publicIdLabel.text = "abc"

    }
    
    override func setTheme() {

        publicIdLabel.textColor = PippipTheme.mediumTextColor
        super.setTheme()
        
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
