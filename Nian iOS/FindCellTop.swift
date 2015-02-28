//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class FindCellTop: UITableViewCell, UIGestureRecognizerDelegate{
    @IBOutlet var viewLeft: UIView!
    @IBOutlet var viewMiddle: UIView!
    @IBOutlet var viewRight: UIView!
    @IBOutlet var imageLeft: UIImageView!
    @IBOutlet var imageMiddle: UIImageView!
    @IBOutlet var imageRight: UIImageView!
    @IBOutlet var viewHolder: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.viewLeft.tag = 1
        self.viewMiddle.tag = 2
        self.viewRight.tag = 3
        self.setWidth(globalWidth)
        self.viewHolder.setX(globalWidth/2 - 160)
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
    }
}
