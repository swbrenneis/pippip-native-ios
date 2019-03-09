//
//  MessageDumpTableViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 9/11/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework

class MessageDumpTableViewController: UITableViewController {

    var contactManager = ContactManager()
    var messageManager = MessageManager()
    var textMessages = [Int: [TextMessage]]()
    var contactIds = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the foreturn
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        var newIndex: Int = 0
        let messages = messageManager.allTextMessages()
        for message in messages {
            if let index = contactIds.index(of: message.contactId) {
                textMessages[index]?.append(message)
            }
            else {
                contactIds.append(message.contactId)
                textMessages[newIndex] = [TextMessage]()
                textMessages[newIndex]?.append(message)
                newIndex += 1
            }
            message.decrypt(notify: false)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        
    }

    func getContactCell(indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageDumpContactCell", for: indexPath)
        let contactId = contactIds[indexPath.section / 2]
        if let contact = ContactsModel.instance.getContact(contactId: contactId) {
            cell.backgroundColor = UIColor.flatTeal
            cell.textLabel?.text = contact.displayName
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
            cell.detailTextLabel?.text = contact.publicId
            cell.detailTextLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        }
        else {
            cell.backgroundColor = UIColor.flatOrangeDark
            cell.textLabel?.text = "Contact not found ( \(contactId) )"
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
            cell.detailTextLabel?.text = "Public ID not found"
            cell.detailTextLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        }
        return cell

    }

    func getMessageCell(indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageDumpPreviewCell", for: indexPath)
        if let messages = textMessages[indexPath.section / 2] {
            cell.textLabel?.text = messages[indexPath.item].cleartext
        }
        return cell
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return contactIds.count * 2

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section % 2 == 0 {
            return 1
        }
        else {
            return textMessages[section / 2]!.count
        }

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section % 2 == 0 {
            return getContactCell(indexPath: indexPath)
        }
        else {
            return getMessageCell(indexPath: indexPath)
        }
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
