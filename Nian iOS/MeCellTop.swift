//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class MeCellTop: UITableViewCell, UIGestureRecognizerDelegate{
    @IBOutlet var viewLeft: UIView!
    @IBOutlet var viewMiddle: UIView!
    @IBOutlet var viewRight: UIView!
    @IBOutlet var numLeft: UILabel!
    @IBOutlet var numMiddle: UILabel!
    @IBOutlet var numRight: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
    }
}
