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
    var currentCell: UITableViewCell?

}

class PublicIdCell: PippipTableViewCell, MultiCellProtocol {

    @IBOutlet weak var publicIdLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    static var cellItem: MultiCellItemProtocol = PublicIdCellItem()
    var viewController: UITableViewController?
    var sessionState = SessionState()

    override public var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        publicIdLabel.text = sessionState.publicId
        attachTapHandler()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func setDarkTheme() {
        
        publicIdLabel.textColor = PippipTheme.darkTextColor
        // titleLabel.textColor = PippipTheme.darkTextColor
        super.setDarkTheme()
        
    }
    
    override func setMediumTheme() {
        
        publicIdLabel.textColor = PippipTheme.mediumTextColor
        //titleLabel.textColor = PippipTheme.mediumTextColor
        super.setMediumTheme()
        
    }
    
    override func setLightTheme() {
        
        publicIdLabel.textColor = PippipTheme.lightTextColor
        // titleLabel.textColor = PippipTheme.lightTextColor
        super.setLightTheme()
        
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