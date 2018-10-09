//
//  PreviewCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework

class PreviewCell: PippipTableViewCell {

    static let secondsPerHour: Int64 = 3600
    static let secondsPerDay: Double = 3600 * 24

    @IBOutlet weak var messageReadIndicator: UIImageView!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!

    var contactManager = ContactManager.instance
    var textMessage: TextMessage?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        NotificationCenter.default.addObserver(self, selector: #selector(sessionEnded(_:)),
//                                               name: Notifications.SessionEnded, object: nil)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(textMessage: TextMessage) {

        messageReadIndicator.isHidden = textMessage.read
        if self.textMessage == nil || self.textMessage?.messageId != textMessage.messageId {
            NotificationCenter.default.addObserver(self, selector: #selector(cleartextAvailable(_:)),
                                                   name: Notifications.CleartextAvailable, object: nil)
            self.textMessage = textMessage
            let contact = contactManager.getContact(contactId: textMessage.contactId)
            senderLabel.text = contact?.displayName
            timestampLabel.text = convertTimestamp(textMessage.timestamp) + " >"
            if textMessage.ciphertext!.count < 25 {
                textMessage.decrypt(notify: false)   // No notification
                setPreviewText(textMessage.cleartext ?? "Text not available")
            }
            else {
                DispatchQueue.global(qos: .background).async {
                    textMessage.decrypt(notify: true)
                }
            }
        }

        //senderLabel.textColor = PippipTheme.darkTextColor
        //previewLabel.textColor = PippipTheme.darkTextColor
        //timestampLabel.textColor = PippipTheme.darkTextColor

        super.setMediumTheme()

    }

    func convertTimestamp(_ timestamp: Int64) -> String {

        let messageDate = Date(timeIntervalSince1970: Double(timestamp / 1000))
        let now = Date()
        let elapsed = now.timeIntervalSince(messageDate)

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
            if textMessage.messageId == self.textMessage?.messageId {
                NotificationCenter.default.removeObserver(self, name: Notifications.CleartextAvailable, object: nil)
                DispatchQueue.main.async {
                    let text = textMessage.cleartext ?? "Text Not Available"
                    self.setPreviewText(text)
                }
            }
        }

    }

//    @objc func sessionEnded(_ notification: Notification) {
//
//        textMessage = nil
//
//    }

}
