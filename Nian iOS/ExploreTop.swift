//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class ExploreTop: UITableViewCell{
    @IBOutlet var View:UIView?
    @IBOutlet var Seg: UISegmentedControl?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.View!.backgroundColor = BGColor
        self.Seg!.tintColor = LineColor
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
    }
    
}
