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

    var blurController: ControllerBlurProtocol!
    var contactManager = ContactManager.instance
    var contactRequests: [ContactRequest]!
    var acknowledgeRequestView: AcknowledgeRequestView?
    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
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

        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "ContactTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ContactRequestCell")
        cancelButton.backgroundColor = PippipTheme.buttonColor
        cancelButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)

        blurView.frame = contentView.frame
        blurView.alpha = 0.0
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurView)

        NotificationCenter.default.addObserver(self, selector: #selector(requestAcknowledged(_:)),
                                               name: Notifications.RequestAcknowledged, object: nil)

    }
    
    func showAckRequestsView(contactRequest: ContactRequest) {
        
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
   
    }
    
    @IBAction func cancelTapped(_ sender: Any) {

        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.blurController.blurView.alpha = 0.0
        }, completion: { completed in
            self.removeFromSuperview()
        })
        
    }
    
    @objc func requestAcknowledged(_ notification: Notification) {
        
        if contactManager.pendingRequests.count > 0 {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        else {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: {
                    self.center.y = 0.0
                    self.alpha = 0.0
                    self.blurController.blurView.alpha = 0.0
                }, completion: { completed in
                    self.removeFromSuperview()
                })
           }
        }

    }

}

extension ContactRequestsView: UITableViewDelegate, UITableViewDataSource  {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contactRequests = Array(contactManager.pendingRequests)
        return contactRequests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let requestCell = tableView.dequeueReusableCell(withIdentifier: "ContactRequestCell") as? ContactTableViewCell
        let request = contactRequests[indexPath.item]
        requestCell?.publicIdLabel.text = request.publicId
        if let directoryId = request.directoryId {
            requestCell?.directoryIdLabel.text = directoryId
        }
        else {
            requestCell?.directoryIdLabel.text = ""
        }
        return requestCell!
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        showAckRequestsView(contactRequest: Array(contactManager.pendingRequests)[indexPath.row])
        
    }

}
