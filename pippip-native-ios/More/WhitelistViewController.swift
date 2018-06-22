//
//  WhitelistViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/24/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import PMAlertController
import ChameleonFramework

class WhitelistViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableBottom: NSLayoutConstraint!
    
    var config = Configurator()
    var nickname = ""
    var publicId = ""
    var contactManager = ContactManager()
    var sessionState = SessionState()
    var suspended = false
    var localAuth: LocalAuthenticator!
    var alertPresenter = AlertPresenter()
    var rightBarItems = [UIBarButtonItem]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = PippipTheme.viewColor
        tableView.delegate = self
        tableView.dataSource = self

        do {
            try config.loadWhitelist()
        }
        catch {
            print("Error loading whitelist: \(error)")
        }

        localAuth = LocalAuthenticator(viewController: self, view: self.view)

        let addFriend = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFriend(_:)))
        rightBarItems.append(addFriend)
        let editFriends = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editFriends(_:)))
        rightBarItems.append(editFriends)
        self.navigationItem.rightBarButtonItems = rightBarItems

        NotificationCenter.default.addObserver(self, selector: #selector(friendDeleted(_:)),
                                               name: Notifications.FriendDeleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(friendAdded(_:)),
                                               name: Notifications.FriendAdded, object: nil)

    }

    override func viewWillAppear(_ animated: Bool) {

        localAuth.listening = true
        alertPresenter.present = true
        NotificationCenter.default.addObserver(self, selector: #selector(localAuthComplete(_:)),
                                               name: Notifications.LocalAuthComplete, object: nil)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        localAuth.listening = false
        alertPresenter.present = false
        NotificationCenter.default.removeObserver(self, name: Notifications.LocalAuthComplete, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func checkSelfAdd(nickname: String?, publicId: String?) -> Bool {
        
        if let nick = nickname {
            let myNick = config.nickname
            if myNick == nick {
                alertPresenter.errorAlert(title: "Add Friend Error", message: "You can't add yourself")
                return true
            }
        }
        if let puid = publicId {
            let myId = sessionState.publicId
            if myId == puid {
                alertPresenter.errorAlert(title: "Add Friend Error", message: "You can't add yourself")
                return true
            }
        }
        return false
        
    }
    
    @objc func addFriend(_ sender: Any) {

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
                                                    self.alertPresenter.errorAlert(title: "Add Friend Error",
                                                                                   message: "You already added that friend")
                                                }
                                            }
                                        }
        }))
        alert.addAction(PMAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true, completion: nil)
        
    }

    @objc func editFriends(_ sender: Any) {

        tableView.setEditing(true, animated: true)
        rightBarItems.removeLast()
        let endEdit = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endEditFriends(_:)))
        rightBarItems.append(endEdit)
        self.navigationItem.rightBarButtonItems = rightBarItems

    }

    @objc func endEditFriends(_ sender: Any) {
        
        tableView.setEditing(false, animated: true)
        rightBarItems.removeLast()
        let editFriends = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editFriends(_:)))
        rightBarItems.append(editFriends)
        self.navigationItem.rightBarButtonItems = rightBarItems

    }

    @objc func friendAdded(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.NicknameMatched, object: nil)
        let entity = Entity(publicId: publicId, nickname: nickname)
        do {
            try config.addWhitelistEntry(entity)
            DispatchQueue.main.async {
                self.tableView.insertRows(at: [IndexPath(row: self.config.whitelist.count-1, section: 0)],
                                          with: .left)
                self.alertPresenter.successAlert(title: "Friend Added",
                                                 message: "This friend has been added to your friends list")
            }
        }
        catch {
            print("Error adding whitelist entry: \(error)")
        }

    }

    @objc func friendDeleted(_ notification:Notification) {

        do {
            let row = try config.deleteWhitelistEntry(self.publicId)
            assert(row != NSNotFound)
            DispatchQueue.main.async {
                self.tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .top)
                self.alertPresenter.successAlert(title: "Friend Deleted",
                                                 message: "This friend has been deleted from your list")
            }
        }
        catch {
            print("Error deleting whitelist entry: \(error)")
        }

    }

    @objc func nicknameMatched(_ notification: Notification) {
        
        NotificationCenter.default.removeObserver(self, name: Notifications.NicknameMatched, object: nil)
        guard let response = notification.object as? MatchNicknameResponse else { return }
        if response.result == "found" {
            publicId = response.publicId!
            if !contactManager.addFriend(self.publicId) {
                alertPresenter.errorAlert(title: "Add Friend Error", message: "You already added that friend")
            }
        }
        else {
            alertPresenter.errorAlert(title: "Add Friend Error", message: "That nickname doesn't exist")
        }

    }

    @objc func localAuthComplete(_ notification: Notification) {
        
        DispatchQueue.main.async {
            self.localAuth.visible = false
        }
        
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

extension WhitelistViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return config.whitelist.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)
            as? PippipTableViewCell else { return UITableViewCell() }
        let entity = config.whitelist[indexPath.row]
        cell.setMediumTheme()
        cell.textLabel?.text = entity.nickname
        cell.detailTextLabel?.text = entity.publicId
        return cell

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 75.0

    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        return true

    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            publicId = config.whitelist[indexPath.row].publicId
            contactManager.deleteFriend(publicId)
        }

    }

}

