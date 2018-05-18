//
//  WhitelistViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/24/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import PMAlertController
import RKDropdownAlert
import ChameleonFramework

class WhitelistViewController: UIViewController, RKDropdownAlertDelegate {

    @IBOutlet weak var tableView: ExpandingTableView!
    @IBOutlet weak var tableBottom: NSLayoutConstraint!
    
    var config = Configurator()
    var tableModel: WhitelistTableModel?
    var nickname = ""
    var publicId = ""
    var contactManager = ContactManager()
    var sessionState = SessionState()
    var suspended = false
    var localAuth: LocalAuthenticator!

    override func viewDidLoad() {
        super.viewDidLoad()

        config.loadWhitelist()

        localAuth = LocalAuthenticator(viewController: self, view: self.view)

        tableModel = WhitelistTableModel(self)
        tableView.expandingModel = tableModel

        tableView.register(FriendCell.self, forCellReuseIdentifier: "FriendCell")

    }

    override func viewWillAppear(_ animated: Bool) {

        tableModel?.setFriends(whitelist: config.whitelist, tableView: tableView)

        localAuth.visible = true
//        NotificationCenter.default.addObserver(self, selector: #selector(appResumed(_:)),
//                                               name: Notifications.AppResumed, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(appSuspended(_:)),
//                                               name: Notifications.AppSuspended, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentAlert(_:)),
                                               name: Notifications.PresentAlert, object: nil)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        localAuth.visible = false
        NotificationCenter.default.removeObserver(self, name: Notifications.PresentAlert, object: nil)
//        NotificationCenter.default.removeObserver(self, name: Notifications.AppResumed, object: nil)
//        NotificationCenter.default.removeObserver(self, name: Notifications.AppSuspended, object: nil)

        tableModel?.clear()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func checkSelfAdd(nickname: String?, publicId: String?) -> Bool {
        
        let alertColor = UIColor.flatSand
        if let nick = nickname {
            let myNick = config.getNickname()
            if myNick == nick {
                RKDropdownAlert.title("Add Friend Error", message: "You can't add yourself",
                                      backgroundColor: alertColor,
                                      textColor: ContrastColorOf(alertColor, returnFlat: true),
                                      time: 2, delegate: nil)
                return true
            }
        }
        if let puid = publicId {
            let myId = sessionState.publicId
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
    
    @IBAction func addFriend(_ sender: Any) {

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
                                                self.contactManager.matchNickname(nickname: self.nickname, publicId: nil)
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
        self.present(alert, animated: true, completion: nil)
        
    }

    @objc func presentAlert(_ notification: Notification) {

        let userInfo = notification.userInfo!
        let title = userInfo["title"] as? String
        let message = userInfo["message"] as? String
        DispatchQueue.main.async {
            let alertColor = UIColor.flatSand
            RKDropdownAlert.title(title, message: message, backgroundColor: alertColor,
                                  textColor: ContrastColorOf(alertColor, returnFlat: true),
                                  time: 2, delegate: self)
        }

    }
/*
    @objc func appResumed(_ notification: Notification) {

        if suspended {
            suspended = false
            if let info = notification.userInfo {
                authView?.suspendedTime = (info["suspendedTime"] as! NSNumber).intValue
            }
            DispatchQueue.main.async {
                self.present(self.authView!, animated: true, completion: nil)
            }
            
        }

    }
    
    @objc func appSuspended(_ notification: Notification) {
        
        suspended = true
        
    }
*/
    @objc func friendAdded(_ : Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.FriendAdded, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.NicknameMatched, object: nil)

        var entity = ["publicId": publicId]
        if (nickname.utf8.count > 0) {
            entity["nickname"] = nickname
        }
        config.addWhitelistEntry(entity)
        DispatchQueue.main.async {
            let alertColor = UIColor.flatLime
            RKDropdownAlert.title("Friend Added", message: "This friend has been added to your friends list",
                                  backgroundColor: alertColor,
                                  textColor: ContrastColorOf(alertColor, returnFlat: true),
                                  time: 2, delegate: nil)
            let friendData = FriendCellData(entity: entity)
            let friendSelector = FriendCellSelector()
            friendSelector.tableView = self.tableView
            friendData.selector = friendSelector
            self.tableView.expandingModel?.appendCell(cellData: friendData, section: 0, with: .left)
        }

    }
    
    @objc func nicknameMatched(_ notification: Notification) {
        
        NotificationCenter.default.removeObserver(self, name: Notifications.NicknameMatched, object: nil)

        let info = notification.userInfo!
        let alertColor = UIColor.flatSand
        if let puid = info["publicId"] as? String {
            publicId = puid
            if !contactManager.addFriend(self.publicId) {
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

    func dropdownAlertWasTapped(_ alert: RKDropdownAlert!) -> Bool {
        return true
    }
    
    func dropdownAlertWasDismissed() -> Bool {
        return true
    }
    
    @IBAction func done(_ sender: Any) {

        dismiss(animated: true, completion: nil)

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

