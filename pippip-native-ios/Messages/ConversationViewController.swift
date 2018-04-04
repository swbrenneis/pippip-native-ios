//
//  ConversationViewController.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/4/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ChameleonFramework

class ConversationViewController: AsyncMessagesViewController {

    var conversationDataSource: ConversationDataSource
    var conversationDelegate: ConversationCollectionDelegate
    var contact: Contact?
    var selectView: SelectContactView?

    init?() {

        conversationDataSource = ConversationDataSource()
        conversationDelegate = ConversationCollectionDelegate()
        
        super.init(dataSource: conversationDataSource, delegate: conversationDelegate)

    }
    
    required init(coder aDecoder: NSCoder) {

        conversationDataSource = ConversationDataSource()
        conversationDelegate = ConversationCollectionDelegate()

        super.init(coder: aDecoder)

    }

    override init?(tableViewStyle style: UITableViewStyle) {

        conversationDataSource = ConversationDataSource()
        conversationDelegate = ConversationCollectionDelegate()
        
        super.init(tableViewStyle: style)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {

        if contact == nil {
            let frame = self.view.bounds
            let viewRect = CGRect(x: 0.0, y: 0.0, width: frame.width * 0.8, height: frame.height * 0.7)
            selectView = SelectContactView(frame: viewRect)
            selectView!.contentView.backgroundColor = UIColor.init(gradientStyle: .topToBottom, withFrame: viewRect, andColors: [UIColor.flatPowderBlue, UIColor.flatSkyBlue])
            selectView!.contentView.alpha = 0.8
            selectView!.center = self.view.center
            self.view.addSubview(selectView!)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}