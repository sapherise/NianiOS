//
//  CustomButton.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/23/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    fileprivate var _spinner: UIActivityIndicatorView?
    fileprivate var _titleString: String?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.cornerRadius = 22.0
        self.layer.masksToBounds = true
        
        self._spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        self._spinner!.isHidden = true
        self.addSubview(self._spinner!)
    }
    
    
    func startAnimating() {
        self._spinner!.frame.origin = CGPoint(x: (self.frame.width - 20)/2, y: (self.frame.height - 20)/2)
        self.setTitle("", for: UIControlState())
        self._spinner!.isHidden = false
        self._spinner!.startAnimating()
    }
    
    func stopAnimating() {
        self._spinner!.stopAnimating()
        self._spinner!.isHidden = true
    }
    
    
}
