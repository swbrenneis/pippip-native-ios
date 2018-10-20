//
//  WhitelistViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/24/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework

class WhitelistViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableBottom: NSLayoutConstraint!
    
    var config = Configurator()
    var directoryId = ""
    var publicId = ""
    var contactManager = ContactManager.instance
    var sessionState = SessionState()
    var suspended = false
    var localAuth: LocalAuthenticator!
    var alertPresenter = AlertPresenter()
    var rightBarItems = [UIBarButtonItem]()
    var addIdView: AddToWhitelistView?
    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Permitted Contacts"
        
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

        localAuth = LocalAuthenticator(viewController: self, initial: false)

        let addWhitelistEntry = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWhitelistEntry(_:)))
        rightBarItems.append(addWhitelistEntry)
        let editWhitelist = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editWhitelist(_:)))
        rightBarItems.append(editWhitelist)
        self.navigationItem.rightBarButtonItems = rightBarItems

    }

    override func viewWillAppear(_ animated: Bool) {

        localAuth.viewWillAppear()
        alertPresenter.present = true

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        alertPresenter.present = false

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        localAuth.viewDidDisappear()
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    func verifyAndAdd(directoryId: String, publicId: String) {

        self.directoryId = directoryId
        self.publicId = publicId

        if !self.checkSelfAdd(directoryId: directoryId, publicId: publicId) {
            if directoryId.utf8.count > 0 {
                NotificationCenter.default.addObserver(self, selector: #selector(directoryIdMatched(_:)),
                                                       name: Notifications.DirectoryIdMatched, object: nil)                
                contactManager.matchDirectoryId(directoryId: directoryId, publicId: nil)
            }
            else if publicId.utf8.count > 0 {
                let regex = try! NSRegularExpression(pattern: "[^A-Fa-f0-9]", options: [])
                if let match = regex.firstMatch(in: publicId,
                                                options: [],
                                                range: NSMakeRange(0, publicId.utf8.count)) {
                    if match.numberOfRanges > 0 || publicId.utf8.count < 40 {
                        alertPresenter.errorAlert(title: "Contact Request Error", message: "Not a valid public ID")
                    }
                }
                else {
                    NotificationCenter.default.addObserver(self, selector: #selector(whitelistEntryAdded(_:)),
                                                           name: Notifications.WhitelistEntryAdded, object: nil)
                    if contactManager.addWhitelistEntry(publicId) {
                        addIdView?.dismiss()
                    }
                    else {
                        self.alertPresenter.errorAlert(title: "Add Permitted ID Error",
                                                   message: "You already added that ID")
                        NotificationCenter.default.removeObserver(self, name: Notifications.WhitelistEntryAdded, object: nil)
                    }
                }
            }
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

    @objc func directoryIdMatched(_ notification: Notification) {
        
        NotificationCenter.default.removeObserver(self, name: Notifications.DirectoryIdMatched, object: nil)
        guard let response = notification.object as? MatchDirectoryIdResponse else { return }
        if response.result == "found" {
            publicId = response.publicId!
            NotificationCenter.default.addObserver(self, selector: #selector(whitelistEntryAdded(_:)),
                                                   name: Notifications.WhitelistEntryAdded, object: nil)
            if contactManager.addWhitelistEntry(publicId) {
                DispatchQueue.main.async {
                    self.addIdView?.dismiss()
                }
            }
            else {
                self.alertPresenter.errorAlert(title: "Add Permitted ID Error",
                                               message: "You already added that ID")
                NotificationCenter.default.removeObserver(self, name: Notifications.WhitelistEntryAdded, object: nil)
            }
        }
        else {
            alertPresenter.errorAlert(title: "Add Permitted ID Error", message: "That directory ID doesn't exist")
        }
        
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

    @objc func whitelistEntryAdded(_ notification: Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.WhitelistEntryAdded, object: nil)
        let entity = Entity(publicId: publicId, directoryId: directoryId)
        do {
            try config.addWhitelistEntry(entity)
            DispatchQueue.main.async {
                self.tableView.insertRows(at: [IndexPath(row: self.config.whitelist.count-1, section: 0)],
                                          with: .left)
//                self.alertPresenter.successAlert(title: "Permitted ID Added",
//                                                 message: "This ID has been added to your permitted contacts list")
            }
        }
        catch {
            print("Error adding whitelist entry: \(error)")
        }

    }

    @objc func whitelistEntryDeleted(_ notification:Notification) {

        NotificationCenter.default.removeObserver(self, name: Notifications.WhitelistEntryDeleted, object: nil)
        do {
            let row = try config.deleteWhitelistEntry(self.publicId)
            assert(row != NSNotFound)
            DispatchQueue.main.async {
                self.tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .top)
//                self.alertPresenter.successAlert(title: "Permitted ID Deleted",
//                                                 message: "This ID has been deleted from your permitted contacts list")
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
        cell.setMediumTheme()
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
            publicId = config.whitelist[indexPath.row].publicId
            contactManager.deleteWhitelistEntry(publicId)
        }

    }

}

