//
//  ContactDetailView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/14/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ContactDetailView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var directoryIdTextField: UITextField!
    @IBOutlet weak var publicIdLabel: UILabel!
    @IBOutlet weak var lastSeenTitle: UILabel!
    @IBOutlet weak var lastSeenLabel: UILabel!
    @IBOutlet weak var resendRequestButton: UIButton!
    @IBOutlet weak var statusImageView: UIImageView!
    
    var blurController: ControllerBlurProtocol?
    var tapGesture: UITapGestureRecognizer?
    var publicId = ""
    var alertPresenter = AlertPresenter()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("ContactDetailView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        resendRequestButton.backgroundColor = PippipTheme.buttonColor
        resendRequestButton.setTitleColor(PippipTheme.buttonTextColor, for: .normal)

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        tapGesture!.numberOfTapsRequired = 1
        tapGesture!.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tapGesture!)

    }
    
    func dismiss() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.center.y = 0.0
            self.alpha = 0.0
            self.blurController?.blurView.alpha = 0.0
        }, completion: { completed in
            self.directoryIdTextField.resignFirstResponder()
        })
        
    }

    func setDetail(contact: Contact) {
        
        assert(Thread.isMainThread)
        publicId = contact.publicId
        publicIdLabel.text = contact.publicId
        directoryIdTextField.text = contact.directoryId
        statusImageView.image = UIImage(named: contact.status)
        resendRequestButton.isHidden = contact.status != "pending"
        let lastSeenFormatter = DateFormatter()
        lastSeenFormatter.dateFormat = "MMM dd YYYY hh:mm"
        if (contact.timestamp == 0) {
            lastSeenLabel.text = "Never"
        }
        else {
            let tsDate = Date.init(timeIntervalSince1970: TimeInterval(contact.timestamp))
            lastSeenLabel.text = lastSeenFormatter.string(from: tsDate)
        }

    }
    
    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        dismiss()
    }
    
    @IBAction func resendRequestTapped(_ sender: Any) {

        ContactManager.instance.requestContact(publicId: publicId, directoryId: nil, retry: true)
        alertPresenter.infoAlert(title: "Contact Request Sent", message: "The request was sent to this contact")
        
    }

}
