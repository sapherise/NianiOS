//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class PlayerCellTop: UITableViewCell, UIGestureRecognizerDelegate{
    
    @IBOutlet var UserHead:UIImageView!
    @IBOutlet var UserName:UILabel!
    @IBOutlet var BGImage:UIImageView!
    @IBOutlet var viewHolder: UIView!
    @IBOutlet var btnMain: UIButton!
    @IBOutlet var btnLetter: UIButton!
    @IBOutlet var UserFo: UILabel!
    @IBOutlet var UserFoed: UILabel!
    @IBOutlet var viewMenu: UIView!
    @IBOutlet var labelMenuLeft: UILabel!
    @IBOutlet var labelMenuRight: UILabel!
    @IBOutlet var labelMenuSlider: UIView!
    @IBOutlet var viewBlack: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.BGImage.clipsToBounds = true
        self.selectionStyle = .None
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
    }
}
