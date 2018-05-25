//
//  SettingsTableViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/19/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import RKDropdownAlert
import ChameleonFramework

class SettingsTableViewController: UITableViewController {

    var cellItems = [Int: [MultiCellItemProtocol]]()
    var config = Configurator()
    var alertPresenter = AlertPresenter()
    var localAuth: LocalAuthenticator!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = PippipTheme.viewColor
        
        self.tableView.dataSource = self
        self.tableView.delegate = self

        localAuth = LocalAuthenticator(viewController: self, view: self.view)

        var items = [MultiCellItemProtocol]()
        items.append(PublicIdCell.cellItem)
        items.append(SetNicknameCell.cellItem)
        items.append(ContactPolicyCell.cellItem)
        items.append(LocalAuthCell.cellItem)
        items.append(CleartextMessagesCell.cellItem)
        items.append(LocalPasswordCell.cellItem)
        let policy = config.contactPolicy
        if policy != "public" {
            items.append(EditWhitelistCell.cellItem)
        }
        cellItems[0] = items
        cellItems[1] = [MultiCellItemProtocol]()
        cellItems[1]?.append(DeleteAccountCell.cellItem)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        localAuth.listening = true
        alertPresenter.present = true
        NotificationCenter.default.addObserver(self, selector: #selector(policyChanged(_:)),
                                               name: Notifications.PolicyChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(thumbprintComplete(_:)),
                                               name: Notifications.ThumbprintComplete, object: nil)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        localAuth.listening = false
        alertPresenter.present = false
        NotificationCenter.default.removeObserver(self, name: Notifications.PolicyChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.ThumbprintComplete, object: nil)

    }

    @objc func policyChanged(_ notification: Notification) {

        guard let info = notification.userInfo else { return }
        guard let policy = info["policy"] as? String else { return }
        if policy == "public" {
            cellItems[0]?.removeLast()
            tableView.deleteRows(at: [IndexPath(row: cellItems[0]!.count, section: 0)], with: .right)
        }
        else {
            cellItems[0]?.append(EditWhitelistCell.cellItem)
            tableView.insertRows(at: [IndexPath(row: cellItems[0]!.count-1, section: 0)], with: .left)
        }


    }

    @objc func thumbprintComplete(_ notification: Notification) {
        
        DispatchQueue.main.async {
            self.localAuth.visible = false
        }
        
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

extension SettingsTableViewController {

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {

        return cellItems.count

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return cellItems[section]?.count ?? 0

    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cellItem = cellItems[indexPath.section]?[indexPath.row] else { return UITableViewCell() }
        guard var cell = tableView.dequeueReusableCell(withIdentifier: cellItem.cellReuseId, for: indexPath)
                            as? MultiCellProtocol else { return UITableViewCell() }
        cell.viewController = self
        guard let pippipCell = cell as? PippipTableViewCell else { return UITableViewCell() }
        if indexPath.section == 0 {
            pippipCell.setMediumTheme()
        }
        else {
            pippipCell.setLightTheme()
            pippipCell.textLabel?.textColor = PippipTheme.buttonLightTextColor
        }

        return pippipCell

    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        guard let cellItem = cellItems[indexPath.section]?[indexPath.row] else { return 0.0 }
        return cellItem.cellHeight

    }

/*
 // Override to support conditional editing of the table view.
 override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
 // Return false if you do not want the specified item to be editable.
 return true
 }
 */

/*
 // Override to support editing the table view.
 override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
 if editingStyle == .delete {
 // Delete the row from the data source
 tableView.deleteRows(at: [indexPath], with: .fade)
 } else if editingStyle == .insert {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
 
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
 // Return false if you do not want the item to be re-orderable.
 return true
 }
 */

}
