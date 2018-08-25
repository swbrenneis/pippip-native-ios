//
//  DirectoryIdCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/19/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class DirectoryIdCellItem: MultiCellItemProtocol {

    var cellReuseId: String = "DirectoryIdCell"
    var cellHeight: CGFloat = 65.0
    var currentCell: UITableViewCell?

}

class DirectoryIdCell: PippipTableViewCell, MultiCellProtocol {

    @IBOutlet weak var directoryIdTextField: UITextField!
    @IBOutlet weak var setDirectoryIdButton: UIButton!

    static var cellItem: MultiCellItemProtocol = DirectoryIdCellItem()
    var viewController: UITableViewController?
    var currentDirectoryId: String?
    var pendingDirectoryId: String?
    var config = Configurator()
    var contactManager = ContactManager()
    var alertPresenter = AlertPresenter()

    override func awakeFromNib() {
        super.awakeFromNib()

        currentDirectoryId = config.directoryId
        if currentDirectoryId != nil {
            directoryIdTextField.text = currentDirectoryId
        }
        else {
            directoryIdTextField.text = ""
        }
        setDirectoryIdButton.isHidden = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            directoryIdTextField.becomeFirstResponder()
        }

    }
/*
    override func setDarkTheme() {
        
        directoryIdTextField.textColor = PippipTheme.darkTextColor
        setDirectoryIdButton.setTitleColor(PippipTheme.buttonDarkTextColor, for: .normal)
        super.setDarkTheme()
        
    }
    
    override func setMediumTheme() {
        
        directoryIdTextField.textColor = PippipTheme.mediumTextColor
        setDirectoryIdButton.setTitleColor(PippipTheme.buttonMediumTextColor, for: .normal)
        super.setMediumTheme()
        
    }
    
    override func setLightTheme() {
        
        directoryIdTextField.textColor = PippipTheme.lightTextColor
        setDirectoryIdButton.setTitleColor(PippipTheme.buttonLightTextColor, for: .normal)
        super.setLightTheme()
        
    }
*/
    @objc func directoryIdMatched(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.DirectoryIdMatched, object: nil)
        guard let response = notification.object as? MatchDirectoryIdResponse else { return }
        if response.result == "not found" {
            NotificationCenter.default.addObserver(self, selector: #selector(directoryIdUpdated(_:)),
                                                   name: Notifications.DirectoryIdUpdated, object: nil)
            DispatchQueue.main.async {
                self.setDirectoryIdButton.isHidden = true
                self.contactManager.updateDirectoryId(newDirectoryId: self.directoryIdTextField.text,
                                                   oldDirectoryId: self.currentDirectoryId)
            }
        }
        else {
            alertPresenter.errorAlert(title: "Directory ID Error",
                                      message: "This directory ID is in use, please choose another")
        }
    }

    @objc func directoryIdUpdated(_ notification: Notification) {
    
        NotificationCenter.default.removeObserver(self, name: Notifications.DirectoryIdUpdated, object: nil)
        guard let response = notification.object as? SetDirectoryIdResponse else { return }
        if response.result == "deleted" {
            currentDirectoryId = nil
        }
        else {
            currentDirectoryId = pendingDirectoryId
        }
        config.directoryId = currentDirectoryId

        var message: String
        if currentDirectoryId != nil {
            message = "Your directory ID has been set to " + currentDirectoryId!
        }
        else {
            message = "Your directory ID has been cleared"
        }
        alertPresenter.successAlert(title: "Directory ID Set", message: message)
        DispatchQueue.main.async {
            self.setDirectoryIdButton.isHidden = true
        }

    }

    @IBAction func directoryIdChanged(_ sender: Any) {

        setDirectoryIdButton.isHidden = currentDirectoryId == directoryIdTextField.text
        
    }

    @IBAction func setDirectoyId(_ sender: Any) {

        pendingDirectoryId = directoryIdTextField.text
        if directoryIdTextField.text!.utf8.count > 0 {
            NotificationCenter.default.addObserver(self, selector: #selector(directoryIdMatched(_:)),
                                                   name: Notifications.DirectoryIdMatched, object: nil)
            contactManager.matchDirectoryId(directoryId: directoryIdTextField.text, publicId: nil)
        }
        else if currentDirectoryId != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(directoryIdUpdated(_:)),
                                                   name: Notifications.DirectoryIdUpdated, object: nil)
            contactManager.updateDirectoryId(newDirectoryId: nil, oldDirectoryId: currentDirectoryId)
        }

    }

}
