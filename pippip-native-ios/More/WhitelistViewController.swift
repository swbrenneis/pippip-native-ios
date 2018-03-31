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
    
    var config: Configurator = ApplicationSingleton.instance().config
    var tableModel: WhitelistTableModel?
    var alertColor = UIColor.flatSand

    override func viewDidLoad() {
        super.viewDidLoad()

        config.loadWhitelist()

        tableModel = WhitelistTableModel(self)
        tableView.expandingModel = tableModel

        tableView.register(FriendCell.self, forCellReuseIdentifier: "FriendCell")

    }

    override func viewWillAppear(_ animated: Bool) {

        tableModel!.setFriends(whitelist: config.whitelist, tableView: tableView)
        NotificationCenter.default.addObserver(self, selector: #selector(presentAlert(_:)),
                                               name: Notifications.PresentAlert, object: nil)

    }

    override func viewWillDisappear(_ animated: Bool) {

        NotificationCenter.default.removeObserver(self, name: Notifications.PresentAlert, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func presentAlert(_ notification: Notification) {

        let userInfo = notification.userInfo!
        let title = userInfo["title"] as? String
        let message = userInfo["message"] as? String
        DispatchQueue.main.async {
            RKDropdownAlert.title(title, message: message, backgroundColor: self.alertColor,
                                  textColor: ContrastColorOf(self.alertColor, returnFlat: true),
                                  time: 2, delegate: self)
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

