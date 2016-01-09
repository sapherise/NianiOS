//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics


class CommentCellMe: UITableViewCell {
    
    @IBOutlet var avatarView:UIImageView!
    @IBOutlet var contentLabel:UILabel!
    @IBOutlet var lastdate:UILabel!
    @IBOutlet var View:UIView!
    @IBOutlet var imageContent:UIImageView!
    var data :NSDictionary!
    var contentLabelWidth:CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.avatarView.layer.masksToBounds = true
        self.avatarView.layer.cornerRadius = 16
    }
    
    func _layoutSubviews() {
        let uid = self.data.stringAttributeForKey("uid")
        let lastdate = self.data.stringAttributeForKey("lastdate")
        let content = self.data.stringAttributeForKey("content")
        self.lastdate!.text = lastdate
        self.avatarView!.setHead(uid)
        
        let height = data.objectForKey("heightContent") as! CGFloat
        let wImage = data.objectForKey("widthImage") as! CGFloat
        let hImage = data.objectForKey("heightImage") as! CGFloat
        
        self.avatarView?.tag = Int(uid)!
        self.contentLabel!.setHeight(height)
        self.contentLabel!.text = content
        
        self.imageContent.setWidth(wImage)
        self.imageContent.setHeight(hImage)
        
        self.contentLabelWidth = data.objectForKey("widthContent") as! CGFloat
        self.avatarView.setBottom(height + 55)
        self.lastdate.setWidth(lastdate.stringWidthWith(11, height: 21))
        self.lastdate.setBottom(height + 60)
        
        self.imageContent.setX(globalWidth - 65 - wImage)
        self.avatarView.setX(globalWidth - 15 - 40)
        self.lastdate.setX(globalWidth - 75 - lastdate.stringWidthWith(11, height: 21))
        self.contentLabel.setX(globalWidth - 80 - self.contentLabelWidth)
    }
}