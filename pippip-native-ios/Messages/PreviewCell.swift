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
    static let secondsPerDay: Double = 3600 * 24

    @IBOutlet weak var messageReadIndicator: UIImageView!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!

    var contactManager = ContactManager()
    var textMessage: TextMessage!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        NotificationCenter.default.addObserver(self, selector: #selector(cleartextAvailable(_:)),
                                               name: Notifications.CleartextAvailable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionEnded(_:)),
                                               name: Notifications.SessionEnded, object: nil)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @objc func configure(_ textMessage: TextMessage) {

        messageReadIndicator.isHidden = textMessage.read
        if self.textMessage == nil || self.textMessage.messageId != textMessage.messageId {
            //configured = true
            self.textMessage = textMessage
            let contact = contactManager.getContactById(textMessage.contactId)
            senderLabel.text = contact?.displayName
            timestampLabel.text = convertTimestamp(textMessage.timestamp) + " >"
            if textMessage.ciphertext!.count < 100 {
                textMessage.decrypt(noNotify: true)   // No notification
                setPreviewText(textMessage.cleartext!)
            }
            else {
                DispatchQueue.global(qos: .background).async {
                    textMessage.decrypt()
                }
            }
        }
        
    }

    func convertTimestamp(_ timestamp: Int64) -> String {

        let messageDate = Date(timeIntervalSince1970: Double(timestamp / 1000))
        let now = Date()
        let elapsed = now.timeIntervalSince(messageDate)
//        let nowTs = Int64(now.timeIntervalSince1970)
//        let secondsSinceMidnight = Int64(now.timeIntervalSince1970) % PreviewCell.secondsPerDay
//        let midnight = Date(timeIntervalSince1970: Double(nowTs - secondsSinceMidnight))
//        let midnightTs = Int64(midnight.timeIntervalSince1970)
//        let yesterday = Date(timeIntervalSince1970: Double(midnightTs - PreviewCell.secondsPerDay))

        if elapsed > PreviewCell.secondsPerDay {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            return formatter.string(from: messageDate)
        }
        else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: messageDate)
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
                    let text = textMessage.cleartext ?? "<nil>"
                    self.setPreviewText(text)
                }
            }
        }

    }

    @objc func sessionEnded(_ notification: Notification) {

        textMessage = nil

    }

}
