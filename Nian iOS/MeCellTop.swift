//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class MeCellTop: UITableViewCell{
    @IBOutlet var viewLeft: UIView!
    @IBOutlet var viewMiddle: UIView!
    @IBOutlet var viewRight: UIView!
    @IBOutlet var numLeft: UILabel!
    @IBOutlet var numMiddle: UILabel!
    @IBOutlet var numRight: UILabel!
    @IBOutlet var viewHolder: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.viewHolder.setX(globalWidth/2-160)
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
    }
}
