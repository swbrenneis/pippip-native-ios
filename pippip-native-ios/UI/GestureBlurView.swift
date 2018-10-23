//
//  GestureBlurView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/21/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class GestureBlurView: UIVisualEffectView {

    var toDismiss: Dismissable?
    var tapGesture: UITapGestureRecognizer!

    override init(effect: UIVisualEffect?) {
        
        super.init(effect: effect)

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tapGesture)
        
    }

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tapGesture)
        
    }

    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        toDismiss?.dismiss()
    }
    
}
