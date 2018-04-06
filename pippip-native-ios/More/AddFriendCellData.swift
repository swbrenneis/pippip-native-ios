//
//  AddFriendCellData.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/30/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import PMAlertController
import ChameleonFramework
import RKDropdownAlert

class AddFriendCellData: CellDataProtocol {

    var cell: UITableViewCell
    var cellHeight: CGFloat
    var selector: ExpandingTableSelectorProtocol
    var userData: [String : Any]?

    init(_ viewController: WhitelistViewController) {

        cell = viewController.tableView.dequeueReusableCell(withIdentifier: "NewFriendCell")!
        cellHeight = 50.0
        selector = AddFriendSelector(viewController)

    }
    
}

class AddFriendSelector: ExpandingTableSelectorProtocol {
    
    weak var viewController: WhitelistViewController?
    var contactManager: ContactManager
    var tableView: ExpandingTableView
    var nickname = ""
    var publicId = ""

    init(_ viewController: WhitelistViewController) {
        
        self.viewController = viewController
        tableView = self.viewController!.tableView
        contactManager = ContactManager()

    }

    func checkSelfAdd(nickname: String?, publicId: String?) -> Bool {

        let alertColor = UIColor.flatSand
        if let nick = nickname {
            let myNick = ApplicationSingleton.instance().config.getNickname()
            if myNick == nick {
                RKDropdownAlert.title("Add Friend Error", message: "You can't add yourself",
                                      backgroundColor: alertColor,
                                      textColor: ContrastColorOf(alertColor, returnFlat: true),
                                      time: 2, delegate: nil)
                return true
            }
        }
        if let puid = publicId {
            let myId = ApplicationSingleton.instance().accountSession.sessionState.publicId
            if myId == puid {
                RKDropdownAlert.title("Add Friend Error", message: "You can't add yourself",
                                      backgroundColor: alertColor,
                                      textColor: ContrastColorOf(alertColor, returnFlat: true),
                                      time: 2, delegate: nil)
                return true
            }
        }
        return false

    }

    func didSelect(_ indexPath: IndexPath) {

        NotificationCenter.default.addObserver(self, selector: #selector(friendAdded(_:)),
                                               name: Notifications.FriendAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(nicknameMatched(_:)),
                                               name: Notifications.NicknameMatched, object: nil)
        
        let alert = PMAlertController(title: "Add A New Friend",
                                      description: "Enter a nickname or public ID",
                                      image: nil,
                                      style: PMAlertControllerStyle.alert)
        alert.addTextField({ (textField) in
            textField?.placeholder = "Nickname"
            textField?.autocorrectionType = .no
            textField?.spellCheckingType = .no
        })
        alert.addTextField({ (textField) in
            textField?.placeholder = "Public ID"
            textField?.autocorrectionType = .no
            textField?.spellCheckingType = .no
        })
        alert.addAction(PMAlertAction(title: "Add Friend",
                                      style: .default, action: { () in
                                        self.nickname = alert.textFields[0].text ?? ""
                                        self.publicId = alert.textFields[1].text ?? ""
                                        if !self.checkSelfAdd(nickname: self.nickname, publicId: self.publicId) {
                                            if self.nickname.utf8.count > 0 {
                                                self.contactManager.matchNickname(self.nickname, withPublicId: nil)
                                            }
                                            else if self.publicId.utf8.count > 0 {
                                                if !self.contactManager.addFriend(self.publicId) {
                                                    let alertColor = UIColor.flatSand
                                                    RKDropdownAlert.title("Add Friend Error", message: "You already added that friend",
                                                                          backgroundColor: alertColor,
                                                                          textColor: ContrastColorOf(alertColor, returnFlat: true),
                                                                          time: 2, delegate: nil)
                                                }
                                            }
                                        }
        }))
        alert.addAction(PMAlertAction(title: "Cancel", style: .cancel))
        viewController?.present(alert, animated: true, completion: nil)

    }
    
    @objc func friendAdded(_ : Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.NicknameMatched, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.FriendAdded, object: nil)
        var entity = [ AnyHashable("publicId"): publicId ]
        if (nickname.utf8.count > 0) {
            entity[AnyHashable("nickname")] = nickname
        }
        let config = ApplicationSingleton.instance().config!
        config.addWhitelistEntry(entity)
        DispatchQueue.main.async {
            let alertColor = UIColor.flatLime
            RKDropdownAlert.title("Friend Added", message: "This friend has been added to your friends list",
                                  backgroundColor: alertColor,
                                  textColor: ContrastColorOf(alertColor, returnFlat: true),
                                  time: 2, delegate: nil)
            let friendCell = self.tableView.dequeueReusableCell(withIdentifier: "FriendCell") as? FriendCell
            friendCell?.cellView?.nicknameLabel.text = self.nickname
            friendCell?.cellView?.publicIdLabel.text = self.publicId
            let cellData = FriendCellData(friendCell: friendCell!, tableView: self.tableView)
            let model = self.tableView.expandingModel!
            model.appendCell(cellData, section: 0)
            self.tableView.insertRows(at: model.insertPaths, with: .left)
        }
    }

    @objc func nicknameMatched(_ notification: Notification) {
        
        let info = notification.userInfo!
        let alertColor = UIColor.flatSand
        if let puid = info["publicId"] as? String {
            publicId = puid
            if !self.contactManager.addFriend(self.publicId) {
                DispatchQueue.main.async {
                    RKDropdownAlert.title("Add Friend Error", message: "You already added that friend",
                                          backgroundColor: alertColor,
                                          textColor: ContrastColorOf(alertColor, returnFlat: true),
                                          time: 2, delegate: nil)
                }
            }
        }
        else {
            DispatchQueue.main.async {
                RKDropdownAlert.title("Add Friend Error", message: "That nickname doesn't exist",
                                      backgroundColor: alertColor,
                                      textColor: ContrastColorOf(alertColor, returnFlat: true),
                                      time: 2, delegate: nil)
            }
        }

    }

}
