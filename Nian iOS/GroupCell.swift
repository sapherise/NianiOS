//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit
import QuartzCore


class GroupCell: UITableViewCell {
    
    @IBOutlet var contentLabel:UILabel?
    @IBOutlet var holder:UILabel?
    @IBOutlet var lastdate:UILabel?
    @IBOutlet var View:UIView?
    
    @IBOutlet var reply:UILabel?
    @IBOutlet var line:UIView?
    
    var largeImageURL:String = ""
    var data :NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .None
        
        
        var tap = UITapGestureRecognizer(target: self, action: "imageViewTapped:")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews()
    {
        
        
        super.layoutSubviews()
        var id = self.data.stringAttributeForKey("id")
        var title = self.data.stringAttributeForKey("title")
        var lastdate = self.data.stringAttributeForKey("lastdate")
        var reply = self.data.stringAttributeForKey("reply")
        
        self.lastdate!.text = lastdate
        self.reply!.text = "\(reply) 回应"
        self.View!.backgroundColor = BGColor
        
        var height = title.stringHeightWith(17,width:242)
        self.contentLabel!.setHeight(height)
        self.contentLabel!.text = title
        self.holder!.layer.cornerRadius = 4;
        self.holder!.layer.masksToBounds = true;
        
        self.holder!.setHeight(height+62)
        
        self.line!.setY(self.contentLabel!.bottom()+15)
        //半圆角
        let maskPath = UIBezierPath(roundedRect: self.line!.bounds, byRoundingCorners: ( UIRectCorner.BottomRight | UIRectCorner.BottomLeft ), cornerRadii: CGSizeMake(4, 4))
        var maskLayer = CAShapeLayer()
        maskLayer.frame = self.line!.bounds;
        maskLayer.path = maskPath.CGPath;
        self.line!.layer.mask = maskLayer;
    }
    
    
    
    class func cellHeightByData(data:NSDictionary)->CGFloat
    {
        var title = data.stringAttributeForKey("title")
        var height = title.stringHeightWith(17,width:242)
            return height + 62.0 + 15.0
    }
    
}
