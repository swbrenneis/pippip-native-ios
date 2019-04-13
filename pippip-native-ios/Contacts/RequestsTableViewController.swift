//
//  RequestsTableViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/12/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import UIKit

class RequestsTableViewController: UITableViewController {

    var requests: [ContactRequest]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = PippipTheme.viewColor
        self.tableView.backgroundColor = PippipTheme.viewColor
        
        self.navigationItem.title = "Contact Requests"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        requests = ContactsModel.instance.pendingRequests
        self.tableView.reloadSections(IndexSet(integer: 0), with: .left)

        NotificationCenter.default.addObserver(self, selector: #selector(requestAcknowledged(_:)),
                                               name: Notifications.RequestAcknowledged, object: nil)

        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: Notifications.RequestAcknowledged, object: nil)
        
    }

    // Notifications
    @objc func requestAcknowledged(_ notification: Notification) {

        guard let contact = notification.object as? Contact else { return }
        var tmp = [ContactRequest]()
        for request in requests! {
            if request.requestingId != contact.publicId {
                tmp.append(request)
            }
        }
        requests = tmp
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: 0), with: .left)
        }
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return requests!.count

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as? RequestsTableViewCell {
            cell.request = requests?[indexPath.row]
            return cell
        }
        else {
            return UITableViewCell()
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
