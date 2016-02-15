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


class CommentCell: UITableViewCell {
    
    @IBOutlet var avatarView:UIImageView!
    @IBOutlet var nickLabel:UILabel!
    @IBOutlet var contentLabel:UILabel!
    @IBOutlet var lastdate:UILabel!
    @IBOutlet var View:UIView!
    @IBOutlet var imageContent:UIImageView!
    var data :NSDictionary!
    var contentLabelWidth:CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.nickLabel!.textColor = UIColor.HightlightColor()
        self.avatarView.layer.masksToBounds = true
        self.avatarView.layer.cornerRadius = 16
    }
    
    func _layoutSubviews() {
        let uid = self.data.stringAttributeForKey("uid")
        let user = self.data.stringAttributeForKey("user")
        let lastdate = self.data.stringAttributeForKey("lastdate")
        let content = self.data.stringAttributeForKey("content")
        self.nickLabel!.text = user
        self.lastdate!.text = lastdate
        self.avatarView!.setHead(uid)
        let height = data.objectForKey("heightContent") as! CGFloat
        let wContent = data.objectForKey("widthContent") as! CGFloat
        let wImage = data.objectForKey("widthImage") as! CGFloat
        let hImage = data.objectForKey("heightImage") as! CGFloat
        
        self.avatarView?.tag = Int(uid)!
        self.contentLabel!.frame.size = CGSizeMake(wContent, height)
        self.contentLabel!.text = content
        self.imageContent.frame.size = CGSizeMake(wImage, hImage)
        self.avatarView.setBottom(height + 55)
        self.nickLabel.setBottom(height + 60)
        self.nickLabel.setWidth(user.stringWidthWith(11, height: 21))
        self.lastdate.setWidth(lastdate.stringWidthWith(11, height: 21))
        self.lastdate.setBottom(height + 60)
        
        self.lastdate.setX(user.stringWidthWith(11, height: 21)+83)
        self.contentLabel.setX(80)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.image = nil
        nickLabel.text = nil
    }
    
}

extension String {
    func toCGFloat() -> CGFloat {
        return CGFloat((self as NSString).floatValue)
    }
}







