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
        self.nickLabel!.textColor = SeaColor
        self.avatarView.layer.masksToBounds = true
        self.avatarView.layer.cornerRadius = 16
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        let uid = self.data.stringAttributeForKey("uid")
        let user = self.data.stringAttributeForKey("user")
        let lastdate = self.data.stringAttributeForKey("lastdate")
        let content = self.data.stringAttributeForKey("content")
        self.nickLabel!.text = user
        self.lastdate!.text = lastdate
        self.avatarView!.setHead(uid)
        let height = content.stringHeightWith(15,width:208)
        self.avatarView?.tag = Int(uid)!
        self.contentLabel!.setHeight(height)
        self.contentLabel!.text = content
        if height == "".stringHeightWith(15,width:208) {      //如果是单行
            let oneLineWidth = content.stringWidthWith(15, height: 24)
            self.imageContent.setWidth(oneLineWidth + 27)
            self.imageContent.setHeight(37)
            self.contentLabelWidth = content.stringWidthWith(15, height: 24)
        }else{      //如果是多行
            self.imageContent.setHeight(height+20)
            self.imageContent.setWidth(235)
            self.contentLabelWidth = 208
        }
        self.avatarView.setBottom(height + 55)
        self.nickLabel.setBottom(height + 60)
        self.nickLabel.setWidth(user.stringWidthWith(11, height: 21))
        self.lastdate.setWidth(lastdate.stringWidthWith(11, height: 21))
        self.lastdate.setBottom(height + 60)
        
        let safeuid = SAUid()
        if uid == safeuid {
            self.imageContent.image = UIImage(named: "bubble_me")
            self.contentLabel.textColor = UIColor.blackColor()
            self.imageContent.setX( globalWidth - 65 - self.imageContent.width())
            self.avatarView.setX(globalWidth - 15 - 40)
            self.nickLabel.hidden = true
            self.lastdate.setX(globalWidth - 75 - lastdate.stringWidthWith(11, height: 21))
            self.contentLabel.setX(globalWidth - 80 - self.contentLabelWidth)
        }else{
            self.imageContent.image = UIImage(named: "bubble")
            self.contentLabel.textColor = UIColor.whiteColor()
            self.imageContent.setX(65)
            self.avatarView.setX(15)
            self.nickLabel.hidden = false
            self.lastdate.setX(user.stringWidthWith(11, height: 21)+83)
            self.contentLabel.setX(80)
        }
    }
    
    class func cellHeightByData(data:NSDictionary)->CGFloat {
        let content = data.stringAttributeForKey("content")
        let height = content.stringHeightWith(15,width:208)
        return height + 60
    }
    
}







