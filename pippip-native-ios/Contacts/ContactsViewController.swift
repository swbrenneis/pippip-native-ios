//
//  ContactsViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/25/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import PMAlertController
import RKDropdownAlert
import ChameleonFramework

class ContactsViewController: UIViewController, RKDropdownAlertDelegate {


    @IBOutlet weak var tableView: ExpandingTableView!
    @IBOutlet weak var tableBottom: NSLayoutConstraint!
    
    var contactManager = ContactManager()
    var contactsModel: ContactsTableModel?
    var headingView: UIView?
    var expandedContact: [ AnyHashable: Any ]?
    var contactIndex = 0
    var requestIndex = 0
    var authView: AuthViewController?
    var debugging = false
    var pendingContactCells = [ UITableViewCell ]()
    var acknowledgedPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contactsModel = ContactsTableModel(self)
        tableView.expandingModel = contactsModel
        authView = AuthViewController()
        authView?.suspended = true

        NotificationCenter.default.addObserver(self, selector: #selector(requestsUpdated(_:)),
                                               name: Notifications.RequestsUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentAlert(_:)),
                                               name: Notifications.PresentAlert, object: nil)

/*
        NotificationCenter.default.addObserver(self, selector: #selector(contactDeleted(_:)),
                                               name: Notifications.ContactDeleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contactRequested(_:)),
                                               name: Notifications.ContactRequested, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(nicknameMatched(_:)),
                                               name: Notifications.NicknameMatched, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(requestAcknowledged(_:)),
                                               name: Notifications.RequestAcknowledged, object: nil)
*/
    }

    override func viewWillAppear(_ animated: Bool) {

        contactsModel!.setContacts(contactManager.getContactList(), viewController: self)
        contactManager.getRequests()

    }
/*
    override func viewWillDisappear(_ animated: Bool) {

//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)

    }
*/
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func nicknameMatched(_ notification: Notification) {

        let info = notification.userInfo
        if let publicId = info?[AnyHashable("publicId")] as? String {
            let nickname = info?[AnyHashable("nickname")] as? String
            DispatchQueue.main.async {
                self.contactManager.requestContact(publicId, withNickname: nickname)
            }
        }
        else {
            let alert = PMAlertController(title: "Add Contact Error",
                                          description: "That nickname doesn't exist",
                                          image: nil,
                                          style: PMAlertControllerStyle.alert)
            alert.addAction(PMAlertAction(title: "OK", style: .default, action: nil))
            self.present(alert, animated: true, completion: nil)
        }

    }

    @objc func requestsUpdated(_ notification: Notification) {
/*
        let info = notification.userInfo
        if let requests = info?[AnyHashable("requests")] as? [ [ AnyHashable: Any ] ] {
            pendingRequests = requests
            if pendingRequests.count > 0 {
            }
        }
*/
    }
    
    @objc func requestAcknowledged(_ notification: Notification) {
/*
        let info = notification.userInfo
        if let pending = info?[AnyHashable("pending")] as? [ [AnyHashable: Any] ] {
            pendingRequests = pending
            DispatchQueue.main.async {
                //self.tableView.closeExpandedCell(IndexPath(row: self.requestIndex + 1, section: 1))
                //self.tableView.deleteRows(at: [IndexPath(row: 1, section: 1)], with: .bottom)
                //self.contactManager.getRequests()
            }
        }
*/
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
    func keyboardWillShow(_ notification: Notification) {
        
        let keyboardInfo = notification.userInfo;
        let keyboardFrame = keyboardInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue;
        let keyboardFrameRect = keyboardFrame?.cgRectValue;
        tableBottom.constant = (keyboardFrameRect?.size.height)!
        let tableHeight = UIEdgeInsetsInsetRect(tableView.frame, tableView.safeAreaInsets).height
        let contentHeight = tableView.contentSize.height
        let offset = CGPoint(x: 0, y: tableHeight - contentHeight - 55.0)
        tableView.setContentOffset(offset, animated: true)
    }
    
    func keyboardDidHide(_ notification: Notification) {
        
        tableBottom.constant = 0.0
        
    }
*/
    // MARK: - ExpandableDelegate
/*
    func numberOfSections(in expandableTableView: ExpandableTableView) -> Int {

        return 2;

    }

    func expandableTableView(_ expandableTableView: ExpandableTableView, numberOfRowsInSection section: Int) -> Int {
    }

    func expandableTableView(_ expandableTableView: ExpandableTableView,
                             cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    }

    func expandableTableView(_ expandableTableView: ExpandableTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.section == 0 {
            return 75.0
        }
        else {
            return 50.0
        }

    }

    func expandableTableView(_ expandableTableView: ExpandableTableView, expandedCellsForRowAt indexPath: IndexPath) -> [UITableViewCell]? {

        tableView.closeAll()
        if indexPath.section == 0 {
            if let contact = contactList?[indexPath.item] {
                expandedContact = contact
                contactIndex = indexPath.item
                // Last seen cell
                let timestamp = contact[AnyHashable("timestamp")] as? NSNumber
                let tsDate = Date.init(timeIntervalSince1970: (timestamp?.doubleValue)!)
                let dayTimePeriodFormatter = DateFormatter()
                dayTimePeriodFormatter.dateFormat = "MMM dd YYYY hh:mm"
                let lastSeenCell = tableView.dequeueReusableCell(withIdentifier: "LastSeenCell") as? LastSeenCell
                lastSeenCell?.lastSeenLabel.text = dayTimePeriodFormatter.string(from: tsDate)
                // Public ID cell
                let publicIdCell =
                    tableView.dequeueReusableCell(withIdentifier: "ContactPublicIdCell") as? ContactPublicIdCell
                let publicId = contact[AnyHashable("publicId")] as? String
                publicIdCell?.publicIdLabel.text = publicId
                let deleteContactCell = tableView.dequeueReusableCell(withIdentifier: "DeleteContactCell")
                return [ publicIdCell!, lastSeenCell!, deleteContactCell! ]
            }
            else {
                return nil
            }
        }
        else if indexPath.item == 1 {
            var cells = [ UITableViewCell ]()
            var index = 0
            while cells.count < pendingRequests!.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PendingContactCell") as? PendingContactCell
                if let nickname = pendingRequests![index][AnyHashable("nickname")] as? String {
                    cell!.nicknameLabel.text = nickname
                }
                else {
                    cell!.nicknameLabel.text = ""
                }
                if let publicId = pendingRequests![index][AnyHashable("publicId")] as? String {
                    cell!.publicIdLabel.text = publicId
                }
                else {
                    cell!.publicIdLabel.text = ""
                }
                cells.append(cell!)
                index += 1
            }
            return cells
        }
        else {
            return nil
        }

    }

    func expandableTableView(_ expandableTableView: ExpandableTableView, heightsForExpandedRowAt indexPath: IndexPath) -> [CGFloat]? {

        if indexPath.section == 0 {
            return [ 63.0, 44.0, 50.0 ]
        }
        else if indexPath.item == 1 {
            return [CGFloat](repeatElement(63.0, count: pendingRequests!.count))
        }
        else {
            return nil
        }

    }

    func expandableTableView(_ expandableTableView: ExpandableTableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 1 {
            switch (indexPath.item) {
            case 0:
                let alert = PMAlertController(title: "Add A New Contact",
                                              description: "Enter a nickname or public ID",
                                              image: nil,
                                              style: PMAlertControllerStyle.alert)
                alert.addTextField({ (textField) in
                    textField?.placeholder = "Nickname"
                })
                alert.addTextField({ (textField) in
                    textField?.placeholder = "Public ID"
                })
                alert.addAction(PMAlertAction(title: "Request Contact",
                                              style: .default, action: { () in
                                                let nickname = alert.textFields[0].text ?? ""
                                                let publicId = alert.textFields[1].text ?? ""
                                                if nickname.utf8.count > 0 {
                                                    self.contactManager.matchNickname(nickname, withPublicId: nil)
                                                }
                                                else if publicId.utf8.count > 0 {
                                                    self.contactManager.requestContact(publicId, withNickname: nickname)
                                                }
                }))
                alert.addAction(PMAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true, completion: nil)
                break;
            case 2:
                if debugging  {
                    contactManager.syncContacts()
                }
                break;
            default:
                break;
            }
        }
    
    }

    func expandableTableView(_ expandableTableView: ExpandableTableView, didSelectExpandedRowAt indexPath: IndexPath) {

        if indexPath.section == 0 && indexPath.item == contactIndex + 3 {
            if let publicId = expandedContact?[AnyHashable("publicId")] as? String {
                let message = "You are about to delete this contact and all of its messages.\n"
                                + "This action cannot be undone.\nContinue?"
                let alert = PMAlertController(title: "Caution!",
                                              description: message,
                                              image: nil,
                                              style: .alert)
                alert.addAction(PMAlertAction(title: "Yes",
                                              style: .default,
                                              action: { () in
                                                self.contactManager.deleteContact(publicId)
                }))
                alert.addAction(PMAlertAction(title: "No", style: .cancel, action:nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else if indexPath.section == 1 {
            requestIndex = indexPath.item - 2;
            if let publicId = pendingRequests![requestIndex][AnyHashable("publicId")] as? String {
                let nickname = pendingRequests![requestIndex][AnyHashable("nickname")] as? String
                let alert = PMAlertController(title: "Pending Request",
                                              description: "Please respond to this request",
                                              image: nil,
                                              style: .alert)
                alert.addAction(PMAlertAction(title: "Accept", style: .default, action: { () in
                    self.acknowledgedPath = indexPath
                    self.contactManager.acknowledgeRequest("accept", withId: publicId, withNickname: nickname)
                }))
                alert.addAction(PMAlertAction(title: "Reject", style: .default, action: { () in
                    self.acknowledgedPath = indexPath
                    self.contactManager.acknowledgeRequest("reject", withId: publicId, withNickname: nickname)
                }))
                alert.addAction(PMAlertAction(title: "Hide", style: .default, action: { () in
                    self.acknowledgedPath = indexPath
                    self.contactManager.acknowledgeRequest("ignore", withId: publicId, withNickname: nickname)
                }))
                alert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }

    }

    func expandableTableView(_ expandableTableView: ExpandableTableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 1 {
            return headingView
        }
        else {
            return nil
        }
        
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView,
                             heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 1 {
            return 40.0
        }
        else {
            return 0.0
        }
        
    }
*/
    func dropdownAlertWasTapped(_ alert: RKDropdownAlert!) -> Bool {
        return true
    }
    
    func dropdownAlertWasDismissed() -> Bool {
        return true
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
