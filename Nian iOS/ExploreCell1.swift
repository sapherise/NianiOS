////
////  YRJokeCell.swift
////  JokeClient-Swift
////
////  Created by YANGReal on 14-6-6.
////  Copyright (c) 2014年 YANGReal. All rights reserved.
////
//
//import UIKit
//import QuartzCore
//
//
//class ExploreCell: UITableViewCell {
//    
//    @IBOutlet var reply:UILabel?
//    @IBOutlet var contentLabel:UILabel?
//    @IBOutlet var holder:UILabel?
//    @IBOutlet var lastdate:UILabel?
//    @IBOutlet var View:UIView?
//    @IBOutlet var line:UIView?
//    var largeImageURL:String = ""
//    var data :NSDictionary!
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        self.selectionStyle = .None
//        
//        
//        var tap = UITapGestureRecognizer(target: self, action: "imageViewTapped:")
//    }
//    
//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        
//        // Configure the view for the selected state
//    }
//    
//    override func layoutSubviews()
//    {
//        
//        
//        super.layoutSubviews()
//        var lastdate = self.data.stringAttributeForKey("lastdate")
//        var title = self.data.stringAttributeForKey("title")
//        var reply = self.data.stringAttributeForKey("reply")
//        
//        self.reply!.text = "\(reply) 回应"
//        self.lastdate!.text = lastdate
//        
//        var height = title.stringHeightWith(17,width:280)
//        
//        
//        
//        self.contentLabel!.setHeight(height)
//        self.contentLabel!.text = title
//        self.holder!.layer.cornerRadius = 4;
//        self.holder!.layer.masksToBounds = true;
//        
//        
//        
//        self.holder!.setHeight(height+62)
//        
//        
//        self.line!.setY(self.contentLabel!.bottom()+15)
//        self.reply!.setY(self.contentLabel!.bottom()+21)
//        self.lastdate!.setY(self.contentLabel!.bottom()+21)
//        
//        //半圆角
//        let maskPath = UIBezierPath(roundedRect: self.line!.bounds, byRoundingCorners: ( UIRectCorner.BottomRight | UIRectCorner.BottomLeft ), cornerRadii: CGSizeMake(4, 4))
//        var maskLayer = CAShapeLayer()
//        maskLayer.frame = self.line!.bounds;
//        maskLayer.path = maskPath.CGPath;
//        self.line!.layer.mask = maskLayer;
//    }
//    
//    
//    
//    class func cellHeightByData(data:NSDictionary)->CGFloat
//    {
//        var title = data.stringAttributeForKey("title")
//        var height = title.stringHeightWith(17,width:280)
//        return height + 62 + 15
//    }
//    
//}
