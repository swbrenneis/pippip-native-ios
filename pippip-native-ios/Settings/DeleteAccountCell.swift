//
//  DeleteAccountCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework

class DeleteAccountCellItem: MultiCellItemProtocol {

    var cellReuseId: String = "DeleteAccountCell"
    var cellHeight: CGFloat = 65.0
    var currentCell: PippipTableViewCell?
    
}

class DeleteAccountCell: PippipTableViewCell, MultiCellProtocol {

    @IBOutlet weak var deleteAccountLabel: UILabel!
    
    static var cellItem: MultiCellItemProtocol = DeleteAccountCellItem()
    var viewController: UITableViewController?

    override func awakeFromNib() {
        super.awakeFromNib()

        deleteAccountLabel.backgroundColor = PippipTheme.lightBarColor
        deleteAccountLabel.textColor = UIColor.flatTealDark
        deleteAccountLabel.layer.cornerRadius = 7.0
        deleteAccountLabel.layer.masksToBounds = true
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            showDeleteAccountView()
        }

    }
    
    func showDeleteAccountView() {
        
        guard let settingsViewController = viewController as? SettingsTableViewController else { return }
        let frame = settingsViewController.view.bounds
        let viewRect = CGRect(x: 0.0, y: 0.0,
                              width: frame.width * PippipGeometry.deleteAccountViewWidthRatio,
                              height: frame.height * PippipGeometry.deleteAccountViewHeightRatio)
        let deleteAccountView = DeleteAccountView(frame: viewRect)
        let viewCenter = CGPoint(x: settingsViewController.view.center.x,
                                 y: deleteAccountView.center.y + PippipGeometry.deleteAccountViewOffset)
        deleteAccountView.center = viewCenter
        deleteAccountView.alpha = 0.3
        deleteAccountView.settingsViewController = settingsViewController
        
        settingsViewController.deleteAccountView = deleteAccountView
        settingsViewController.view.addSubview(deleteAccountView)
        
        UIView.animate(withDuration: 0.3, animations: {
            settingsViewController.blurView.alpha = 0.6
            deleteAccountView.alpha = 1.0
        })
        
    }

}
