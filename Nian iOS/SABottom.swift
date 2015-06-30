//
//  SABottom.swift
//  Nian iOS
//
//  Created by Sa on 15/6/2.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
class SABottom: UIView {
    @IBOutlet var viewLine: UIView!
    
    var pointX: CGFloat = 0
    var pointY: CGFloat = 0
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setWidth(globalWidth)
        self.viewLine.setWidth(globalWidth)
        self.viewLine.setHeight(0.5)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.frame.origin = CGPointMake(pointX, pointY)
    }
}