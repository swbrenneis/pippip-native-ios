//
//  InitialViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/11/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import UIKit
import FrostedSidebar
import ImageSlideshow
import ChameleonFramework
import Tabman
import Pageboy

class InitialViewController: TabmanViewController {

    var messagesPreviewController: MessagesViewController?
    var composeViewController: ComposeViewController?
    var contactsViewController: ContactsViewController?
    var settingsViewController: SettingsTableViewController?
    var authenticator: Authenticator?
    var alertPresenter = AlertPresenter()
    var tabTag: Int = 1
    //var messagesDecorator = MessagesContainerDecorator()
    
//    var menuSidebar: FrostedSidebar?
 //   var sidebarOn = false
    /*
    var slideshow: ImageSlideshow!
    let slides = [ImageSource(imageString: "quickstart01")!,
                  ImageSource(imageString: "quickstart02")!,
                  ImageSource(imageString: "quickstart03")!,
                  ImageSource(imageString: "quickstart04")!,
                  ImageSource(imageString: "quickstart05")!,
                  ImageSource(imageString: "quickstart06")!,
                  ImageSource(imageString: "quickstart07")!,
                  ImageSource(imageString: "quickstart08")!,
                  ImageSource(imageString: "quickstart09")!,
                  ImageSource(imageString: "quickstart10")!,
                  ImageSource(imageString: "quickstart11")!,
                  ImageSource(imageString: "quickstart12")!,
                  ImageSource(imageString: "quickstart13")!]
*/
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        PippipTheme.setTheme()
        PippipGeometry.setGeometry()
        SecommAPI.initializeAPI()
        AccountSession.initialViewController = self

        try! AccountSession.instance.loadAccount()
        authenticator = Authenticator(viewController: self)

        self.navigationController?.navigationBar.barTintColor = PippipTheme.navBarColor
        self.navigationController?.navigationBar.tintColor = PippipTheme.navBarTint
        self.navigationItem.title = "Message Previews"
        
        contactsViewController = self.storyboard?.instantiateViewController(withIdentifier: "ContactsViewController") as? ContactsViewController
        settingsViewController = self.storyboard?.instantiateViewController(withIdentifier: "SettingsTableViewController") as? SettingsTableViewController
        messagesPreviewController = self.storyboard?.instantiateViewController(withIdentifier: "MessagesViewController") as? MessagesViewController
        composeViewController = self.storyboard?.instantiateViewController(withIdentifier: "ComposeViewController") as? ComposeViewController

        self.dataSource = self
        // Create bar
        let bar = TMBar.ButtonBar()
        bar.backgroundView.style = .flat(color: PippipTheme.viewColor)
        bar.indicator.tintColor = PippipTheme.navBarColor
        bar.layout.transitionStyle = .snap // Customize
        bar.layout.contentInset = UIEdgeInsets(top: 8.0, left: 12.0, bottom: 8.0, right: 12.0)
        bar.layout.interButtonSpacing = 12.0
        bar.buttons.customize({button in
            button.tintColor = PippipTheme.navBarColor.withAlphaComponent(0.5)
            button.selectedTintColor = PippipTheme.navBarColor
            button.backgroundColor = PippipTheme.lightBarColor
            button.layer.cornerRadius = 7.0
            button.contentInset = UIEdgeInsets(top: 8.0, left: 10.0, bottom: 8.0, right: 10.0)
        })
        // Add to view
        addBar(bar, dataSource: self, at: .bottom)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appSuspended(_:)),
                                               name: Notifications.AppSuspended, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setNavBarTitle(_:)),
                                               name: Notifications.SetNavBarTitle, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        authenticator?.viewWillAppear()
        alertPresenter.present = true
/*
        switch tabTag {
        case 1:
            messagesDecorator.setNavBarItems()
        case 2:
            setContactsNavBarItems()
        case 3:
            setSettingsNavBarItems()
        default:
            break
        }
  */

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        authenticator?.viewDidAppear()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        alertPresenter.present = false
        authenticator?.viewWillDisappear()

    }
    
    func accountDeleted() {
        authenticator?.accountDeleted()
    }
    
    func setMessagesNavBarItems() {
        
        let composeImage = UIImage(named: "compose-small")?.withRenderingMode(.alwaysOriginal)
        let compose = UIBarButtonItem(image: composeImage, style: .plain,
                                      target: self, action: #selector(composeMessage(_:)))
        var leftBarItems = [UIBarButtonItem]()
        leftBarItems.append(compose)
        self.navigationItem.leftBarButtonItems = leftBarItems
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.title = "Messages"

    }
    
    func setComposeNavBarItems() {
        
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelCompose(_:)))
        self.navigationItem.rightBarButtonItems = [ cancelItem ]
        self.navigationItem.leftBarButtonItems = nil

    }

    func setContactsNavBarItems() {
        
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContact(_:)))
        self.navigationItem.rightBarButtonItems = [ addItem ]
        self.navigationItem.leftBarButtonItems = nil
        self.navigationItem.title = "Contacts"
        
    }
    
    func setSettingsNavBarItems() {
        
        self.navigationItem.leftBarButtonItems = nil
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.title = "Settings"
        
    }
    
    // Selectors

    @objc func composeMessage(_ sender: Any) {
//        messagesDecorator.viewMode = .compose
        setComposeNavBarItems()
    }
    
    @objc func addContact(_ sender: Any) {
        contactsViewController?.addContact()
    }
    
    @objc func cancelCompose(_ sender: Any) {
//        messagesDecorator.viewMode = .preview
        setMessagesNavBarItems()
    }
    
    @objc func didTap() {
  /*
        UIView.animate(withDuration: 0.3, animations: {
            self.slideshow.alpha = 0.0
        }, completion: { (completed) in
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        })
    */
    }
/*
    @objc func showSidebar(_ item: Any) {
        
        self.view.endEditing(true)
        if sidebarOn {
            sidebarOn = false
            menuSidebar?.dismissAnimated(true, completion: nil)
        }
        else {
            sidebarOn = true
            menuSidebar?.showInViewController(self, animated: true)
        }
        
    }
*/
    // Notifications

    // Notifications

    @objc func appSuspended(_ notification: Notification) {
/*
        DispatchQueue.main.async {
            self.sidebarOn = false
            self.menuSidebar?.dismissAnimated(true, completion: nil)
        }
*/
    }

    @objc func setNavBarTitle(_ notification: Notification) {
        
        guard let title = notification.object as? String else { return }
        self.navigationItem.title = title
        
    }

}

extension InitialViewController : PageboyViewControllerDataSource, TMBarDataSource {
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        
        let item = TMBarItem(title: "lolwut?")
        switch index {
        case 0:
            item.title = "Messages"
            item.image = UIImage(named: "messages-small")
        case 1:
            item.title = "Compose"
            item.image = UIImage(named: "compose-small")
        case 2:
            item.title = "Contacts"
            item.image = UIImage(named: "contacts-small")
        case 3:
            item.title = "Settings"
            item.image = UIImage(named: "settings-small")
        default:
            break
        }
        return item
        
    }

    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return 4
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        
        switch index {
        case 0:
            return messagesPreviewController
        case 1:
            return composeViewController
        case 2:
            return contactsViewController
        case 3:
            return settingsViewController
        default:
            return nil
        }

    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
//        return .first
        return nil
    }

}
