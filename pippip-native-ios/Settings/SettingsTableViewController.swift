//
//  SettingsTableViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/19/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework

class SettingsTableViewController: UITableViewController, ControllerBlurProtocol {

    var cellItems = [Int: [MultiCellItemProtocol]]()
    var accountName: String!
    var wasReset = false
    var config = Configurator()
    var alertPresenter: AlertPresenter!
    var authenticator: Authenticator!
    var deleteAccountView: DeleteAccountView?
    var verifyPassphraseView: VerifyPassphraseView?
    var changePassphraseView: ChangePassphraseView?
    var storePassphraseView: StorePassphraseView?
    var blurView = GestureBlurView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))

    override func viewDidLoad() {
        super.viewDidLoad()

        accountName = AccountSession.instance.accountName
        self.view.backgroundColor = PippipTheme.viewColor
        let frame = self.view.bounds
        blurView.frame = frame
        blurView.alpha = 0.0
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurView)
        self.navigationItem.title = "Settings"

        alertPresenter = AlertPresenter(view: self.view)
    
        self.tableView.dataSource = self
        self.tableView.delegate = self

        authenticator = Authenticator(viewController: self)

        var items = [MultiCellItemProtocol]()
        items.append(PublicIdCell.cellItem)
        items.append(DirectoryIdCell.cellItem)
        items.append(LocalPassphraseCell.cellItem)
        items.append(LocalAuthCell.cellItem)
        items.append(ShowIgnoredCell.cellItem)
        items.append(AutoAcceptCell.cellItem)
        items.append(ContactPolicyCell.cellItem)
        let policy = config.contactPolicy
        if policy != "public" {
            items.append(EditWhitelistCell.cellItem)
        }
        cellItems[0] = items
        cellItems[1] = [MultiCellItemProtocol]()
        cellItems[1]?.append(DeleteAccountCell.cellItem)

        NotificationCenter.default.addObserver(self, selector: #selector(resetControllers(_:)),
                                               name: Notifications.ResetControllers, object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        authenticator.viewWillAppear()
        alertPresenter.present = true

        if wasReset {
            wasReset = false
            tableView.reloadData()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(policyChanged(_:)),
                                               name: Notifications.PolicyChanged, object: nil)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        alertPresenter.present = false
        authenticator.viewWillDisappear()

        verifyPassphraseView?.dismiss()
        storePassphraseView?.dismiss()
        changePassphraseView?.dismiss()
        deleteAccountView?.dismiss(blurViewOff: true)

        for section in self.cellItems.keys {
            for item in self.cellItems[section]! {
                item.currentCell?.reset()
            }
        }
        self.wasReset = true

        NotificationCenter.default.removeObserver(self, name: Notifications.PolicyChanged, object: nil)

    }
/*
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        localAuth.viewDidDisappear()
        
    }
*/
    func accountDeleted() {
        
        assert(Thread.isMainThread, "accountDeleted must be called from main thread")
        navigationController?.popViewController(animated: true)
        
    }
    
    func showChangePassphraseView() {
        
        let frame = self.view.bounds
        let viewRect = CGRect(x: 0.0, y: 0.0,
                              width: frame.width * PippipGeometry.changePassphraseViewWidthRatio,
                              height: frame.height * PippipGeometry.changePassphraseViewHeightRatio)
        changePassphraseView = ChangePassphraseView(frame: viewRect)
        changePassphraseView?.accountName = accountName
        let viewCenter = CGPoint(x: self.view.center.x, y: changePassphraseView!.center.y + PippipGeometry.changePassphraseViewOffset)
        changePassphraseView?.center = viewCenter
        changePassphraseView?.alpha = 0.0
        
        changePassphraseView?.settingsViewController = self
        
        self.view.addSubview(self.changePassphraseView!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView.alpha = 0.6
            self.changePassphraseView?.alpha = 1.0
        }, completion: { completed in
            self.navigationController?.setNavigationBarHidden(PippipGeometry.changePassphraseViewHideNavBar, animated: true)
            self.changePassphraseView?.oldPassphraseTextView.becomeFirstResponder()
        })
        
    }

    func showStorePassphraseView(cell: LocalAuthCell) {
        
        let frame = self.view.bounds
        let viewRect = CGRect(x: 0.0, y: 0.0,
                              width: frame.width * PippipGeometry.storePassphraseViewWidthRatio,
                              height: frame.height * PippipGeometry.storePassphraseViewHeightRatio)
        storePassphraseView = StorePassphraseView(frame: viewRect)
        storePassphraseView?.accountName = accountName
        storePassphraseView?.cell = cell
        storePassphraseView?.alpha = 0.0
        
        storePassphraseView?.settingsViewController = self
        
        self.view.addSubview(self.storePassphraseView!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.storePassphraseView?.alpha = 1.0
            self.blurView.alpha = 0.6
            self.storePassphraseView?.passphraseTextField.becomeFirstResponder()
            let viewCenter = CGPoint(x: self.view.center.x, y: self.storePassphraseView!.center.y + PippipGeometry.storePassphraseViewOffset)
            self.storePassphraseView?.center = viewCenter
        })
        
    }

    // Notifications
    @objc func policyChanged(_ notification: Notification) {

        guard let policy = notification.object as? String else { return }
        DispatchQueue.main.async {
            if policy == "public" {
                self.cellItems[0]?.removeLast()
                self.tableView.deleteRows(at: [IndexPath(row: self.cellItems[0]!.count, section: 0)], with: .right)
            }
            else {
                self.cellItems[0]?.append(EditWhitelistCell.cellItem)
                self.tableView.insertRows(at: [IndexPath(row: self.cellItems[0]!.count-1, section: 0)], with: .left)
            }
        }

    }
    
    @objc func resetControllers(_ notification: Notification) {

        DispatchQueue.main.async {
            for section in self.cellItems.keys {
                for item in self.cellItems[section]! {
                    item.currentCell?.reset()
                }
            }
            self.wasReset = true
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

        guard var cellItem = cellItems[indexPath.section]?[indexPath.row] else { return UITableViewCell() }
        guard var cell = tableView.dequeueReusableCell(withIdentifier: cellItem.cellReuseId, for: indexPath)
                            as? MultiCellProtocol else { return UITableViewCell() }
        cell.viewController = self
        guard let pippipCell = cell as? PippipTableViewCell else { return UITableViewCell() }
        pippipCell.configure()
        pippipCell.setTheme()
        cellItem.currentCell = pippipCell

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
