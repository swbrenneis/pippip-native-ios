//
//  WhitelistViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/24/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework
import CocoaLumberjack

class WhitelistViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableBottom: NSLayoutConstraint!
    
    var config = Configurator()
    var contactManager = ContactManager.instance
    var sessionState = SessionState()
    var wasReset = false
    var authenticator: Authenticator!
    var alertPresenter = AlertPresenter()
    var rightBarItems = [UIBarButtonItem]()
    var addIdView: AddToWhitelistView?
    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Permitted IDs"
        
        self.view.backgroundColor = PippipTheme.viewColor
        let frame = self.view.bounds
        blurView.frame = frame
        blurView.alpha = 0.0
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurView)

        tableView.delegate = self
        tableView.dataSource = self

        do {
            try config.loadWhitelist()
        }
        catch {
            print("Error loading whitelist: \(error)")
        }

        authenticator = Authenticator(viewController: self)

        let addWhitelistEntry = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWhitelistEntry(_:)))
        rightBarItems.append(addWhitelistEntry)
        let editWhitelist = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editWhitelist(_:)))
        rightBarItems.append(editWhitelist)
        self.navigationItem.rightBarButtonItems = rightBarItems

        NotificationCenter.default.addObserver(self, selector: #selector(resetControllers(_:)),
                                               name: Notifications.ResetControllers, object: nil)

    }

    override func viewWillAppear(_ animated: Bool) {

        authenticator.viewWillAppear()
        alertPresenter.present = true
        
        if wasReset {
            wasReset = false
            tableView.reloadData()
        }

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        alertPresenter.present = false
        authenticator.viewWillDisappear()

    }
/*
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        localAuth.viewDidDisappear()
    
    }
*/
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addToWhitelist(publicId: String, directoryId: String?) {

        if checkContactExists(publicId: publicId) {
            self.alertPresenter.errorAlert(title: "Add Permitted ID Error",
                                           message: "You already added that ID")
            NotificationCenter.default.removeObserver(self, name: Notifications.WhitelistEntryAdded, object: nil)
        }
        else {
            do {
                try contactManager.addWhitelistEntry(publicId: publicId, directoryId: directoryId)
                DispatchQueue.main.async {
                    self.addIdView?.dismiss()
                }
            }
            catch {
                DDLogError("Error adding ID to whitelist: \(error.localizedDescription)")
                self.alertPresenter.errorAlert(title: "Add Permitted ID Error",
                                               message: "An error occurred, please try again")
                NotificationCenter.default.removeObserver(self, name: Notifications.WhitelistEntryAdded, object: nil)
            }
        }

    }
    
    func checkContactExists(publicId: String) -> Bool {
        
        guard let _ = config.whitelistIndexOf(publicId: publicId) else { return false }
        return true
        
    }
    
    func checkSelfAdd(directoryId: String?, publicId: String?) -> Bool {
        
        if let nick = directoryId {
            let myNick = config.directoryId
            if myNick == nick {
                alertPresenter.errorAlert(title: "Add Permitted ID Error", message: "You can't add yourself")
                return true
            }
        }
        if let puid = publicId {
            let myId = sessionState.publicId
            if myId == puid {
                alertPresenter.errorAlert(title: "Add Permitted ID Error", message: "You can't add yourself")
                return true
            }
        }
        return false
        
    }

    func verifyAndAdd(directoryId: String?, publicId: String?) {

        guard !self.checkSelfAdd(directoryId: directoryId, publicId: publicId) else { return }
        if let dId = directoryId {
            NotificationCenter.default.addObserver(self, selector: #selector(directoryIdMatched(_:)),
                                                   name: Notifications.DirectoryIdMatched, object: nil)
            contactManager.matchDirectoryId(directoryId: dId, publicId: nil)
        }
        else if let pId = publicId {
            NotificationCenter.default.addObserver(self, selector: #selector(whitelistEntryAdded(_:)),
                                                   name: Notifications.WhitelistEntryAdded, object: nil)
            addToWhitelist(publicId: pId, directoryId: nil)
        }
        else {
            DDLogError("Verify and add error: No valid IDs provided")
        }

    }

    @objc func addWhitelistEntry(_ sender: Any) {

        let frame = self.view.bounds
        let viewRect = CGRect(x: 0.0, y: 0.0,
                              width: frame.width * PippipGeometry.addToWhitelistViewWidthRatio,
                              height: frame.height * PippipGeometry.addToWhitelistViewHeightRatio)
        addIdView = AddToWhitelistView(frame: viewRect)
        let viewCenter = CGPoint(x: self.view.center.x, y: self.view.center.y - PippipGeometry.addToWhitelistViewOffset)
        addIdView?.center = viewCenter
        addIdView?.alpha = 0.0
        
        addIdView?.whitelistViewController = self
        
        self.view.addSubview(self.addIdView!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.addIdView?.alpha = 1.0
            self.blurView.alpha = 0.6
        }, completion: { complete in
            self.addIdView?.directoryIdTextField.becomeFirstResponder()
        })
        
    }

    @objc func editWhitelist(_ sender: Any) {

        tableView.setEditing(true, animated: true)
        rightBarItems.removeLast()
        let endEdit = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endEditWhitelist(_:)))
        rightBarItems.append(endEdit)
        self.navigationItem.rightBarButtonItems = rightBarItems

    }

    @objc func endEditWhitelist(_ sender: Any) {
        
        tableView.setEditing(false, animated: true)
        rightBarItems.removeLast()
        let editWhitelist = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editWhitelist(_:)))
        rightBarItems.append(editWhitelist)
        self.navigationItem.rightBarButtonItems = rightBarItems

    }

    // Notifications
    
    @objc func directoryIdMatched(_ notification: Notification) {
        
        NotificationCenter.default.removeObserver(self, name: Notifications.DirectoryIdMatched, object: nil)
        guard let response = notification.object as? MatchDirectoryIdResponse else { return }
        if response.result == "found" {
            if let publicId = response.publicId {
                NotificationCenter.default.addObserver(self, selector: #selector(whitelistEntryAdded(_:)),
                                                       name: Notifications.WhitelistEntryAdded, object: nil)
                addToWhitelist(publicId: publicId, directoryId: response.directoryId)
            }
            else {
                alertPresenter.errorAlert(title: "Add Permitted ID Error", message: "Invalid response from server")
                DDLogError("Server did not return public ID on match")
            }
        }
        else {
            alertPresenter.errorAlert(title: "Add Permitted ID Error", message: "That directory ID doesn't exist")
        }
        
    }
    
    @objc func resetControllers(_ notification: Notification) {

        wasReset = true
        
    }
    
    @objc func whitelistEntryAdded(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.WhitelistEntryAdded, object: nil)
        guard let userInfo = notification.userInfo else { return }
        guard let publicId = userInfo["publicId"] as? String else { return }
        let entity = Entity(publicId: publicId, directoryId: userInfo["directoryId"] as? String)
        do {
            try config.addWhitelistEntry(entity)
            DispatchQueue.main.async {
                self.tableView.insertRows(at: [IndexPath(row: self.config.whitelist.count-1, section: 0)],
                                          with: .left)
            }
        }
        catch {
            DDLogError("Error adding whitelist entry: \(error.localizedDescription)")
            alertPresenter.errorAlert(title: "Add Permitted ID Error", message: "And error occurred, please try again")
        }

    }

    @objc func whitelistEntryDeleted(_ notification:Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.WhitelistEntryDeleted, object: nil)
        guard let userInfo = notification.userInfo else { return }
        guard let publicId = userInfo["publicId"] as? String else { return }
        do {
            let row = try config.deleteWhitelistEntry(publicId)
            assert(row != NSNotFound)
            DispatchQueue.main.async {
                self.tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .top)
            }
        }
        catch {
            print("Error deleting whitelist entry: \(error)")
        }

    }
/*
    @objc func localAuthComplete(_ notification: Notification) {
        
        DispatchQueue.main.async {
            self.localAuth.showAuthView = false
        }
        
    }
*/
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

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WhitelistCell", for: indexPath)
            as? PippipTableViewCell else { return UITableViewCell() }
        let entity = config.whitelist[indexPath.row]
        cell.setTheme()
        cell.textLabel?.text = entity.directoryId
        cell.detailTextLabel?.text = entity.publicId
        return cell

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 75.0

    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        return true

    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            NotificationCenter.default.addObserver(self, selector: #selector(whitelistEntryDeleted(_:)),
                                                   name: Notifications.WhitelistEntryDeleted, object: nil)
            let publicId = config.whitelist[indexPath.row].publicId
            contactManager.deleteWhitelistEntry(publicId: publicId)
        }

    }

}

