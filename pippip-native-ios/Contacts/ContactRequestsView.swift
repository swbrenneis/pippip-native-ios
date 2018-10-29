//
//  ContactRequestsView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/5/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ContactRequestsView: UIView, ControllerBlurProtocol {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var blurController: ControllerBlurProtocol!
    var contactRequests: [ContactRequest]!
    var selected: ContactRequest?
    //var acknowledgeRequestView: AcknowledgeRequestView?
    var blurView = GestureBlurView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
    var navigationController: UINavigationController?   // This is to satisfy the protocol. DO NOT USE!

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        
        Bundle.main.loadNibNamed("ContactRequestsView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true

        titleLabel.textColor = PippipTheme.titleColor
        titleLabel.backgroundColor = PippipTheme.lightBarColor
        tableView.delegate = self
        tableView.dataSource = self
        let contactNib = UINib(nibName: "ContactTableViewCell", bundle: nil)
        tableView.register(contactNib, forCellReuseIdentifier: "ContactRequestCell")
        let ackNib = UINib(nibName: "AcknowledgeRequestTableViewCell", bundle: nil)
        tableView.register(ackNib, forCellReuseIdentifier: "AcknowledgeRequestCell")
        cancelButton.backgroundColor = PippipTheme.cancelButtonColor
        cancelButton.setTitleColor(PippipTheme.cancelButtonTextColor, for: .normal)

        blurView.frame = contentView.frame
        blurView.alpha = 0.0
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurView)

        NotificationCenter.default.addObserver(self, selector: #selector(requestAcknowledged(_:)),
                                               name: Notifications.RequestAcknowledged, object: nil)

    }
    
    func showAckRequestsView(contactRequest: ContactRequest) {
        
        /*
        let frame = contentView.frame
        let viewRect = CGRect(x: 0.0, y: 0.0,
                              width: frame.width * PippipGeometry.ackRequestViewWidthRatio,
                              height: frame.height * PippipGeometry.ackRequestViewHeightRatio)
        acknowledgeRequestView = AcknowledgeRequestView(frame: viewRect)
        acknowledgeRequestView!.blurController = self
        acknowledgeRequestView!.alpha = 0.0
        acknowledgeRequestView!.center = contentView.center
        acknowledgeRequestView?.contactRequest = contactRequest
        
        addSubview(acknowledgeRequestView!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView.alpha = 0.6
            self.acknowledgeRequestView!.alpha = 1.0
        })
   */
    }
    
    func ackCanceled() {
        
        assert(Thread.isMainThread, "ackCanceled must be called from the main thread")
        if ContactManager.instance.pendingRequests.count > 0 {
            tableView.separatorStyle = .singleLine
            tableView.reloadSections(IndexSet(integer: 0), with: .left)
        }
        else {
            dismiss()
        }

    }
    
    func dismiss() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.blurController.blurView.alpha = 0.0
        }, completion: { completed in
            self.removeFromSuperview()
        })
        
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
    
        if let _ = selected {
            selected = nil
            ackCanceled()
        }
        else {
            dismiss()
        }
        
    }
    
    @objc func requestAcknowledged(_ notification: Notification) {
        
        DispatchQueue.main.async {
            if ContactManager.instance.pendingRequests.count > 0 {
                self.tableView.separatorStyle = .singleLine
                self.tableView.reloadSections(IndexSet(integer: 0), with: .left)
            }
            else {
                self.dismiss()
            }
        }

    }

}

extension ContactRequestsView: UITableViewDelegate, UITableViewDataSource  {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let _ = selected {
            return 4
        }
        else {
            contactRequests = Array(ContactManager.instance.pendingRequests)
            return contactRequests.count
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let _ = selected {
            return getAckCell(indexPath: indexPath)
        }
        else {
            return getContactRequestCell(indexPath: indexPath)
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let _ = selected {
            if indexPath.row == 0 {
                return 65.0
            }
            else {
                return 45.0
            }
        }
        else {
            return 65.0
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if selected == nil {
            selected = contactRequests[indexPath.row]
            tableView.separatorStyle = .none
            tableView.reloadSections(IndexSet(integer: 0), with: .left)
        }

    }

    func getContactRequestCell(indexPath: IndexPath) -> UITableViewCell {
        
        guard let requestCell = tableView.dequeueReusableCell(withIdentifier: "ContactRequestCell") as? ContactTableViewCell
            else { return UITableViewCell() }
        let request = contactRequests[indexPath.item]
        requestCell.publicIdLabel.text = request.publicId
        if let directoryId = request.directoryId {
            requestCell.directoryIdLabel.text = directoryId
        }
        else {
            requestCell.directoryIdLabel.text = ""
        }
        return requestCell
        
    }

    func getAckCell(indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            guard let requestCell = tableView.dequeueReusableCell(withIdentifier: "ContactRequestCell") as? ContactTableViewCell
                else { return UITableViewCell() }
            requestCell.publicIdLabel.text = selected!.publicId
            if let directoryId = selected!.directoryId {
                requestCell.directoryIdLabel.text = directoryId
            }
            else {
                requestCell.directoryIdLabel.text = ""
            }
            return requestCell
        case 1:
            guard let ackCell = tableView.dequeueReusableCell(withIdentifier: "AcknowledgeRequestCell") as? AcknowledgeRequestTableViewCell
                else { return UITableViewCell() }
            ackCell.configure(cellType: .accept, reqView: self)
            return ackCell
        case 2:
            guard let ackCell = tableView.dequeueReusableCell(withIdentifier: "AcknowledgeRequestCell") as? AcknowledgeRequestTableViewCell
                else { return UITableViewCell() }
            ackCell.configure(cellType: .reject, reqView: self)
            return ackCell
        case 3:
            guard let ackCell = tableView.dequeueReusableCell(withIdentifier: "AcknowledgeRequestCell") as? AcknowledgeRequestTableViewCell
                else { return UITableViewCell() }
            ackCell.configure(cellType: .ignore, reqView: self)
            return ackCell
            /*
        case 4:
            guard let ackCell = tableView.dequeueReusableCell(withIdentifier: "AcknowledgeRequestCell") as? AcknowledgeRequestTableViewCell
                else { return UITableViewCell() }
            ackCell.configure(cellType: .cancel, reqView: self)
            return ackCell
 */
        default:
            return UITableViewCell()
        }

    }

}
