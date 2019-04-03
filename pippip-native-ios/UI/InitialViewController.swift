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

class InitialViewController: UITabBarController {
    
//    var messagesContainerViewController: MessagesContainerViewController?
    var composeController: UIViewController?
    var contactsViewController: ContactsViewController?
    var settingsViewController: SettingsTableViewController?
    var authenticator: Authenticator?
    var alertPresenter = AlertPresenter()
    var tabTag: Int = 1
    var messagesDecorator = MessagesContainerDecorator()
    
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
        self.tabBar.tintColor = PippipTheme.viewTextColor
        self.tabBar.barTintColor = PippipTheme.viewColor
        
        contactsViewController = (self.storyboard?.instantiateViewController(withIdentifier: "ContactsViewController") as! ContactsViewController)
        contactsViewController?.tabBarItem = UITabBarItem(title: "Contacts", image: UIImage(named: "contacts-small"), tag: 2)
        contactsViewController?.title = "Contacts"
        settingsViewController = (self.storyboard?.instantiateViewController(withIdentifier: "SettingsTableViewController") as! SettingsTableViewController)
        settingsViewController?.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "settings-small"), tag: 3)
        settingsViewController?.title = "Settings"

        let messagesContainerViewController = self.storyboard?.instantiateViewController(withIdentifier: "MessagesContainerViewController") as? MessagesContainerViewController
        messagesContainerViewController?.tabBarItem = UITabBarItem(title: "Messages", image: UIImage(named: "messages-small"), tag: 1)
        messagesContainerViewController?.title = "Messages"
        let messagesPreviewController = self.storyboard?.instantiateViewController(withIdentifier: "MessagesViewController") as? MessagesViewController
        let composeViewController = self.storyboard?.instantiateViewController(withIdentifier: "ComposeViewController") as? ComposeViewController
        messagesDecorator.containerController = messagesContainerViewController
        messagesDecorator.previewController = messagesPreviewController
        messagesDecorator.composeController = composeViewController
        messagesDecorator.initialController = self
        messagesDecorator.viewMode = .preview
        messagesContainerViewController?.decorator = messagesDecorator
        composeViewController?.decorator = messagesDecorator
        messagesContainerViewController?.decorator = messagesDecorator

        let controllers = [ messagesContainerViewController!, contactsViewController!, settingsViewController! ]
        self.viewControllers = controllers
/*
        let sidebarImages = [ UIImage(named: "help")!, UIImage(named: "settings")!,
                              UIImage(named: "exit")! ]
        let sidebar = FrostedSidebar(itemImages: sidebarImages, colors: nil, selectionStyle: .single)
        sidebar.showFromRight = true
        sidebar.itemBackgroundColor = .clear
        sidebar.adjustForNavigationBar = true
        sidebar.itemSize = CGSize(width: 130.0, height: 130.0)
        sidebar.actionForIndex[0] = {
            self.sidebarOn = false
            self.menuSidebar?.dismissAnimated(true, completion: nil)
            UIView.animate(withDuration: 0.3, animations: {
                self.slideshow.alpha = 1.0
            }, completion: { (completed) in
                self.navigationController?.setNavigationBarHidden(true, animated: true)
            })
        }
        sidebar.actionForIndex[1] = {
            self.sidebarOn = false
            self.menuSidebar?.dismissAnimated(true, completion: nil)
            //self.navigationController?.pushViewController(self.settingsView, animated: true)
        }
        sidebar.actionForIndex[2] = {
            self.sidebarOn = false
            self.menuSidebar?.dismissAnimated(true, completion: nil)
            AccountSession.instance.signOut()
            //self.authenticator.signOut()
        }
        menuSidebar = sidebar
        let bounds = self.view.bounds
        slideshow = ImageSlideshow(frame: bounds)
        slideshow.setImageInputs(slides)
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        slideshow.addGestureRecognizer(recognizer)
        slideshow.alpha = 0.0
        self.view.addSubview(slideshow)
  */

        NotificationCenter.default.addObserver(self, selector: #selector(appSuspended(_:)),
                                               name: Notifications.AppSuspended, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setNavBarTitle(_:)),
                                               name: Notifications.SetNavBarTitle, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        authenticator?.viewWillAppear()
        alertPresenter.present = true

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
        messagesDecorator.viewMode = .compose
        setComposeNavBarItems()
    }
    
    @objc func addContact(_ sender: Any) {
        contactsViewController?.addContact()
    }
    
    @objc func cancelCompose(_ sender: Any) {
        messagesDecorator.viewMode = .preview
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

// Tab bar delegate
extension InitialViewController {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

        tabTag = item.tag
        
        switch tabTag {
        case 1:
            setMessagesNavBarItems()
        case 2:
            setContactsNavBarItems()
        case 3:
            setSettingsNavBarItems()
        default:
            break
        }
        
    }

}
