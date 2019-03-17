//
//  RequestsTableViewCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/12/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import UIKit

class RequestsTableViewCell: UITableViewCell {

    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    
    var request: ContactRequest? {
        didSet {
            self.displayNameLabel.text = request!.displayId
        }
    }
    var contactManager = ContactManager()
    var alertPresentert = AlertPresenter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        acceptButton.backgroundColor = PippipTheme.buttonColor
        acceptButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        hideButton.backgroundColor = PippipTheme.cancelButtonColor
        hideButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)
        rejectButton.backgroundColor = PippipTheme.rejectButtonColor
        rejectButton.setTitleColor(PippipTheme.rejectButtonTextColor, for: .normal)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func acceptTapped(_ sender: Any) {
        
        contactManager.acknowledgeRequest(contactRequest: request!, response: "accept")

    }
    
    @IBAction func hideTapped(_ sender: Any) {
        
        contactManager.acknowledgeRequest(contactRequest: request!, response: "ignore")

    }

    @IBAction func rejectTapped(_ sender: Any) {
        
        contactManager.acknowledgeRequest(contactRequest: request!, response: "reject")

    }
}
