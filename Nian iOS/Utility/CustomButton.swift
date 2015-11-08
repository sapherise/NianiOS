//
//  CustomButton.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/23/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    private var _spinner: UIActivityIndicatorView?
    private var _titleString: String?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.cornerRadius = 22.0
        self.layer.masksToBounds = true
        
        self._spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        self._spinner!.hidden = true
        self.addSubview(self._spinner!)
    }
    
    
    func startAnimating() {
        self._spinner!.frame.origin = CGPointMake((self.frame.width - 20)/2, (self.frame.height - 20)/2)
        self.setTitle("", forState: UIControlState.Normal)
        self._spinner!.hidden = false
        self._spinner!.startAnimating()
    }
    
    func stopAnimating() {
        self._spinner!.stopAnimating()
        self._spinner!.hidden = true
    }
    
    
}
