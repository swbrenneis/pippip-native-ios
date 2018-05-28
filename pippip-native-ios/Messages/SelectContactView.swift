//
//  SelectContactView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/4/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class SelectContactView: UIView {

    @IBOutlet var contentView: SelectContactView!
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectButton: UIButton!
    
    var contactList = [Contact]()
    var contactManager = ContactManager()
    var lastPartialLength = 0
    var selected: Contact?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func commonInit() {

        Bundle.main.loadNibNamed("SelectContactView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        searchText.becomeFirstResponder()
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "ContactTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SelectContactCell")
        selectButton.isEnabled = false
        selectButton.isHidden = true

    }

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    @IBAction func selectContact(_ sender: Any) {

        if selected != nil {
            AsyncNotifier.notify(name: Notifications.ContactSelected, object: selected!)
            self.removeFromSuperview()
        }

    }

    @IBAction func searchChanged(_ sender: Any) {

        selectButton.isEnabled = false
        let partial = searchText.text!
        let fragment = partial.uppercased()
        let newLength = partial.utf8.count

        var newList = [Contact]()
        if partial.utf8.count == 0 {
            contactList.removeAll()
        }
        else if newLength == 1 || newLength < lastPartialLength {
            newList.append(contentsOf: contactManager.searchContacts(fragment))
        }
        else {
            for contact in contactList {
                let publicId = contact.publicId.uppercased()
                if publicId.contains(fragment) {
                    newList.append(contact)
                }
                else if let nickname = contact.nickname?.uppercased() {
                    if nickname.contains(fragment) {
                        newList.append(contact)
                    }
                }
            }
        }
        contactList.removeAll()
        for contact in newList {
            if contact.status == "accepted" {
                contactList.append(contact)
            }
        }
        lastPartialLength = newLength
        tableView.reloadData()

    }

}

extension SelectContactView: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let selectCell = tableView.dequeueReusableCell(withIdentifier: "SelectContactCell") as? ContactTableViewCell
        let contact = contactList[indexPath.item]
        selectCell?.publicIdLabel.text = contact.publicId
        if let nickname = contact.nickname {
            selectCell?.nicknameLabel.text = nickname
        }
        else {
            selectCell?.nicknameLabel.text = ""
        }
        return selectCell!

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selected = contactList[indexPath.item]
        selectButton.isEnabled = true
        selectButton.isHidden = false
        searchText.text = selected!.displayName

    }

}

