//
//  ContactCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/25/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ContactCell: ExpandingTableViewCell {

    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var identLabel: UILabel!

    override var cellHeight: CGFloat {
        get {
            return 63.0
        }
        set {
            // noop
        }
    }

    var publicId: String?
    var contact: Contact? {
        didSet {
            identLabel.text = contact!.displayName
            statusImageView.image = UIImage(named: contact!.status)
            publicId = contact!.publicId
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(pendingContactsUpdated(_:)),
                                               name: Notifications.PendingContactsUpdated, object: nil)
        
   }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    deinit {
        
        NotificationCenter.default.removeObserver(self, name: Notifications.PendingContactsUpdated,
                                                  object: nil)
        
    }
    
    @objc func pendingContactsUpdated(_ notification: Notification) {
        
        if let contacts = notification.object as? [Contact] {
            for updated in contacts {
                if updated.publicId == publicId {
                    DispatchQueue.main.async {
                        self.statusImageView.image = UIImage.init(named: updated.status)
                    }
                }
            }
        }
        
    }

}
