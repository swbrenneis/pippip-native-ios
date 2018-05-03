//
//  PreviewCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class PreviewCell: UITableViewCell {

    static let secondsPerHour: Int64 = 3600
    static let secondsPerDay: Int64 = 3600 * 24

    @IBOutlet weak var messageReadIndicator: UIImageView!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!

    var contactManager = ContactManager()
    var configured = false
    var textMessage: TextMessage!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        NotificationCenter.default.addObserver(self, selector: #selector(cleartextAvailable(_:)),
                                               name: Notifications.CleartextAvailable, object: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @objc func configure(_ textMessage: TextMessage) {

        messageReadIndicator.isHidden = textMessage.read
        if !configured {
            configured = true
            self.textMessage = textMessage
            let contact = contactManager.getContactById(textMessage.contactId)
            senderLabel.text = contact?.displayName
            timestampLabel.text = convertTimestamp(textMessage.timestamp) + " >"
            if textMessage.ciphertext!.count < 100 {
                textMessage.decrypt(true)   // No notification
                setPreviewText(textMessage.cleartext!)
            }
            else {
                textMessage.decrypt(false)
            }
        }
        
    }

    func convertTimestamp(_ timestamp: Int64) -> String {

        let ts = timestamp / 1000
        let now = Int64(Date().timeIntervalSince1970)
        let secondsSinceMidnight = now % PreviewCell.secondsPerHour
        let midnight = now - secondsSinceMidnight
        let yesterday = midnight - PreviewCell.secondsPerDay

        if ts < yesterday {
            let time = Date(timeIntervalSince1970: Double(ts))
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            return formatter.string(from: time)
        }
        else if ts < midnight {
            return "Yesterday"
        }
        else {
            let time = Date(timeIntervalSince1970: Double(ts))
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return formatter.string(from: time)
        }

    }

    func setPreviewText(_ text: String?) {

        guard let _ = text else { return }
        if text!.utf8.count > 33 {
            previewLabel.text = text!.prefix(33) + " ..."
        }
        else {
            previewLabel.text = text
        }

    }

    @objc func cleartextAvailable(_ notification: Notification) {

        if let textMessage = notification.object as? TextMessage {
            if textMessage.messageId == self.textMessage.messageId {
                DispatchQueue.main.async {
                    self.setPreviewText(textMessage.cleartext)
                }
            }
        }

    }

}
