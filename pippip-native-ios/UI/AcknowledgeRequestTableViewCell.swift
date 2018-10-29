//
//  AcknowledgeRequestTableViewCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/28/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework

enum CellType {
    case accept
    case ignore
    case reject
    // case cancel
}

class AcknowledgeRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var nibView: UIView!
    @IBOutlet weak var acknowledgeButton: UIButton!
    
    var cellType: CellType!
    var reqView: ContactRequestsView!
    var request: ContactRequest?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(cellType: CellType, reqView: ContactRequestsView) {
        
        self.reqView = reqView
        self.cellType = cellType

        switch cellType {
        case .accept:
            acknowledgeButton.setTitle("Accept", for: .normal)
            acknowledgeButton.backgroundColor = PippipTheme.buttonColor
            acknowledgeButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
            break
        case .ignore:
            acknowledgeButton.setTitle("Delete", for: .normal)
            acknowledgeButton.backgroundColor = UIColor.flatGrayDark
            acknowledgeButton.setTitleColor(ContrastColorOf(UIColor.flatGrayDark, returnFlat: true), for: .normal)
            break
        case .reject:
            acknowledgeButton.setTitle("Reject", for: .normal)
            acknowledgeButton.backgroundColor = UIColor.flatOrange
            acknowledgeButton.setTitleColor(ContrastColorOf(UIColor.flatOrange, returnFlat: true), for: .normal)
            break
            /*
        case .cancel:
            acknowledgeButton.setTitle("Cancel", for: .normal)
            acknowledgeButton.backgroundColor = PippipTheme.cancelButtonColor
            acknowledgeButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)
            break
 */
        }

    }
    
    @IBAction func acknowledgeTapped(_ sender: Any) {

        guard let request = reqView.selected else { return }
        reqView.selected = nil
        reqView.tableView.separatorStyle = .singleLine

        switch cellType! {
        case .accept:
            ContactManager.instance.acknowledgeRequest(contactRequest: request, response: "accept")
            break
        case .ignore:
            ContactManager.instance.acknowledgeRequest(contactRequest: request, response: "ignore")
            break
        case .reject:
            ContactManager.instance.acknowledgeRequest(contactRequest: request, response: "reject")
            break
            /*
        case .cancel:
            reqView.ackCanceled()
            break
             */
        }        
    }

}
