//
//  CleartextMessagesCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/10/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import PMAlertController

class CleartextMessagesCellItem: MultiCellItemProtocol {

    var cellReuseId: String = "CleartextMessagesCell"
    var cellHeight: CGFloat = 65.0
    var currentCell: UITableViewCell?

}

class CleartextMessagesCell: PippipTableViewCell, MultiCellProtocol {

    static var cellItem: MultiCellItemProtocol = CleartextMessagesCellItem()
    var viewController: UITableViewController?    

    @IBOutlet weak var cleartextMessagesSwitch: UISwitch!

    var config = Configurator()
    var messageManager = MessageManager()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        let cleartext = config.storeCleartextMessages
        cleartextMessagesSwitch.setOn(!cleartext, animated: true)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func doDecrypt() {

        let hud = MBProgressHUD.showAdded(to: self.superview!, animated: true)
        hud.mode = .indeterminate
        hud.label.text = "Decrypting messages"
        DispatchQueue.main.async {
            self.messageManager.decryptAll()
            MBProgressHUD.hide(for: self.superview!, animated: true)
        }

    }

    func doWarning() {

        let message = "Disabling extra message security will result in a performance increase,"
                        + " but your messages could potentially be read if your device is lost or stolen\n"
                        + "Do you want to continue?"
        let alert = PMAlertController(title: "Caution!", description: message, image: nil, style: .alert)
        alert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
            self.config.storeCleartextMessages = true
            self.doDecrypt()
        }))
        alert.addAction(PMAlertAction(title: "No", style: .cancel))
        viewController?.present(alert, animated: true, completion: nil)

    }

    @IBAction func cleartextSelected(_ sender: UISwitch) {

        if cleartextMessagesSwitch.isOn {
            let hud = MBProgressHUD.showAdded(to: self.superview!, animated: true)
            hud.mode = .indeterminate
            hud.label.text = "Scrubbing messages"
            config.storeCleartextMessages = false
            DispatchQueue.main.async {
                self.messageManager.scrubCleartext()
                MBProgressHUD.hide(for: self.superview!, animated: true)
            }
        }
        else {
            doWarning()
        }

    }
}
