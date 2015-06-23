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
    @IBOutlet weak var heightLine: NSLayoutConstraint!
    var pointX: CGFloat = 0
    var pointY: CGFloat = 0
    override func awakeFromNib() {
        self.setWidth(globalWidth)
        heightLine.constant = 0.5
    }
    
    override func layoutSubviews() {
        self.frame.origin = CGPointMake(pointX, pointY)
    }
}