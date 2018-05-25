//
//  NicknameCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/19/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class SetNicknameCellItem: MultiCellItemProtocol {

    var cellReuseId: String = "SetNicknameCell"
    var cellHeight: CGFloat = 65.0
    var currentCell: UITableViewCell?

}

class SetNicknameCell: PippipTableViewCell, MultiCellProtocol {

    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var setNicknameButton: UIButton!

    static var cellItem: MultiCellItemProtocol = SetNicknameCellItem()
    var viewController: UITableViewController?
    var currentNickname: String?
    var pendingNickname: String?
    var config = Configurator()
    var contactManager = ContactManager()
    var alertPresenter = AlertPresenter()

    override func awakeFromNib() {
        super.awakeFromNib()

        currentNickname = config.nickname
        if currentNickname != nil {
            nicknameTextField.text = currentNickname
        }
        else {
            nicknameTextField.text = ""
        }
        setNicknameButton.isHidden = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            nicknameTextField.becomeFirstResponder()
        }

    }

    override func setDarkTheme() {
        
        nicknameTextField.textColor = PippipTheme.darkTextColor
        setNicknameButton.setTitleColor(PippipTheme.buttonDarkTextColor, for: .normal)
        super.setDarkTheme()
        
    }
    
    override func setMediumTheme() {
        
        nicknameTextField.textColor = PippipTheme.mediumTextColor
        setNicknameButton.setTitleColor(PippipTheme.buttonMediumTextColor, for: .normal)
        super.setMediumTheme()
        
    }
    
    override func setLightTheme() {
        
        nicknameTextField.textColor = PippipTheme.lightTextColor
        setNicknameButton.setTitleColor(PippipTheme.buttonLightTextColor, for: .normal)
        super.setLightTheme()
        
    }
    
    @objc func nicknameMatched(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.NicknameMatched, object: nil)
        if let info = notification.userInfo {
            if info["publicId"] == nil {
                NotificationCenter.default.addObserver(self, selector: #selector(nicknameUpdated(_:)),
                                                       name: Notifications.NicknameUpdated, object: nil)
                DispatchQueue.main.async {
                    self.setNicknameButton.isHidden = true
                    self.contactManager.updateNickname(newNickname: self.nicknameTextField.text,
                                                       oldNickname: self.currentNickname)
                }
            }
            else {
                alertPresenter.errorAlert(title: "Nickname Error",
                                          message: "This nickname is in use, please choose another nickname")
            }
        }

    }

    @objc func nicknameUpdated(_ notification: Notification) {
    
        NotificationCenter.default.removeObserver(self, name: Notifications.NicknameUpdated, object: nil)
        guard let info = notification.userInfo else { return }
        guard let result = info["result"] as? String else { return }
        if result == "deleted" {
            currentNickname = nil
        }
        else {
            currentNickname = pendingNickname
        }
        config.nickname = currentNickname!

        var message: String
        if currentNickname != nil {
            message = "Your nickname has been set to " + currentNickname!
        }
        else {
            message = "Your nickname has been cleared"
        }
        alertPresenter.successAlert(title: "Nickname Set", message: message)
        DispatchQueue.main.async {
            self.setNicknameButton.isHidden = true
        }

    }

    @IBAction func nicknameChanged(_ sender: Any) {

        setNicknameButton.isHidden = currentNickname == nicknameTextField.text
        
    }

    @IBAction func setNickname(_ sender: Any) {

        pendingNickname = nicknameTextField.text
        if nicknameTextField.text!.utf8.count > 0 {
            NotificationCenter.default.addObserver(self, selector: #selector(nicknameMatched(_:)),
                                                   name: Notifications.NicknameMatched, object: nil)
            contactManager.matchNickname(nickname: nicknameTextField.text, publicId: nil)
        }
        else if currentNickname != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(nicknameUpdated(_:)),
                                                   name: Notifications.NicknameUpdated, object: nil)
            contactManager.updateNickname(newNickname: nil, oldNickname: currentNickname)
        }

    }

}
