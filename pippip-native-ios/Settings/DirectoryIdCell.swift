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
    var currentCell: PippipTableViewCell?

}

class DirectoryIdCell: PippipTableViewCell, MultiCellProtocol, UITextFieldDelegate {

    @IBOutlet weak var directoryIdTextField: UITextField!
    @IBOutlet weak var setDirectoryIdButton: UIButton!

    static var cellItem: MultiCellItemProtocol = DirectoryIdCellItem()
    var viewController: UITableViewController?
    var currentDirectoryId: String!
    var pendingDirectoryId: String?
    var config = Configurator()
    var contactManager = ContactManager.instance
    var alertPresenter = AlertPresenter()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    override func configure() {
        
        currentDirectoryId = config.directoryId ?? ""
        directoryIdTextField.text = currentDirectoryId
        setDirectoryIdButton.isHidden = true
        setDirectoryIdButton.backgroundColor = PippipTheme.buttonColor
        setDirectoryIdButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        directoryIdTextField.delegate = self
        
    }

    // Reset to configuration default.
    override func reset() {

        directoryIdTextField.text = ""

    }
    
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
            DispatchQueue.main.async {
                self.directoryIdTextField.text = self.config.directoryId
                self.setDirectoryIdButton.isHidden = true
            }
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
        alertPresenter.successAlert(message: message)
        DispatchQueue.main.async {
            self.setDirectoryIdButton.isHidden = true
            self.directoryIdTextField.resignFirstResponder()
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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        directoryIdTextField.resignFirstResponder()
        return true

    }
    
}
