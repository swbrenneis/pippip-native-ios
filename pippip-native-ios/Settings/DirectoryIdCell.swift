//
//  DirectoryIdCell.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/19/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import CocoaLumberjack

class DirectoryIdCellItem: MultiCellItemProtocol {

    var cellReuseId: String = "DirectoryIdCell"
    var cellHeight: CGFloat = 65.0
    var currentCell: PippipTableViewCell?

}

class DirectoryIdCell: PippipTableViewCell, MultiCellProtocol, UITextFieldDelegate {

    @IBOutlet weak var directoryIdTextField: UITextField!
    @IBOutlet weak var setDirectoryIdButton: UIButton!

    static var cellItem: MultiCellItemProtocol = DirectoryIdCellItem()
    var viewController: UITableViewController?
    var currentDirectoryId = ""
    var config = Configurator()
    var directoryManager = DirectoryManager()
    var alertPresenter = AlertPresenter()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    override func configure() {
        
        currentDirectoryId = config.directoryId ?? ""
        directoryIdTextField.text = currentDirectoryId
        setDirectoryIdButton.isHidden = true
        setDirectoryIdButton.backgroundColor = PippipTheme.buttonColor
        setDirectoryIdButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)
        directoryIdTextField.delegate = self
        
    }

    // Reset to configuration default.
    override func reset() {

        directoryIdTextField.text = ""

    }
    
    func directoryIdUpdated(result: String, newDirectoryId: String) {
        
        switch result {
        case SetDirectoryIdResponse.deleted:
            self.currentDirectoryId = ""
            self.config.directoryId = nil
            self.alertPresenter.successAlert(message: "Your directory ID has been cleared")
            DispatchQueue.main.async {
                self.setDirectoryIdButton.isHidden = true
                self.directoryIdTextField.resignFirstResponder()
            }
            break
        case SetDirectoryIdResponse.added, SetDirectoryIdResponse.updated:
            self.config.directoryId = newDirectoryId
            self.currentDirectoryId = newDirectoryId
            self.alertPresenter.successAlert(message: "Your directory ID has been set to \(newDirectoryId)")
            DispatchQueue.main.async {
                self.setDirectoryIdButton.isHidden = true
                self.directoryIdTextField.resignFirstResponder()
            }
            break
        case SetDirectoryIdResponse.in_use:
            self.alertPresenter.errorAlert(title: "Directory ID Error",
                                           message: "This ID is in use, please choose another")
            DispatchQueue.main.async {
                self.directoryIdTextField.text = self.config.directoryId
                self.setDirectoryIdButton.isHidden = true
            }
            break
        default:
            break
        }

    }

    @IBAction func directoryIdChanged(_ sender: Any) {

        setDirectoryIdButton.isHidden = currentDirectoryId == directoryIdTextField.text
        
    }

    @IBAction func setDirectoyId(_ sender: Any) {

        let newDirectoryId = directoryIdTextField.text ?? ""
        directoryManager.setDirectoryId(oldId: currentDirectoryId, newId: newDirectoryId,
                                        onResponse: { response in
                                            self.directoryIdUpdated(result: response.result!, newDirectoryId: newDirectoryId)
                                        },
                                        onError: { error in
                                            DDLogError("Set directory ID error: \(error)")
                                            self.alertPresenter.errorAlert(title: "Directory ID error",
                                                                           message: "The request could not be completed, please try again")
                                        })

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        directoryIdTextField.resignFirstResponder()
        return true

    }
    
}
