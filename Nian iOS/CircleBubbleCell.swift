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


class CircleBubbleCell: UITableViewCell {
    
    @IBOutlet var avatarView:UIImageView!
    @IBOutlet var nickLabel:UILabel!
    @IBOutlet var contentLabel:UILabel!
    @IBOutlet var lastdate:UILabel!
    @IBOutlet var View:UIView!
    @IBOutlet var textContent: UIImageView!
    var activity: UIActivityIndicatorView?
    var data :NSDictionary!
    var contentLabelWidth:CGFloat = 0
    var isDream: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.nickLabel!.textColor = SeaColor
        self.avatarView.layer.masksToBounds = true
        self.avatarView.layer.cornerRadius = 20
        self.View.userInteractionEnabled = true
        self.setWidth(globalWidth)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var uid = self.data.stringAttributeForKey("uid")
        var user = self.data.stringAttributeForKey("user")
        var lastdate = self.data.stringAttributeForKey("lastdate")
        var content = self.data.stringAttributeForKey("content")
        if isDream == 1 {
            content = "更新了梦想「\(content)」"
        }
        var cid = self.data.stringAttributeForKey("cid")
        var type = (self.data.objectForKey("type") as! String).toInt()!
        self.nickLabel!.text = user
        self.lastdate!.text = lastdate
        self.avatarView.setHead(uid)
        var height = content.stringHeightWith(15,width:208)
        self.avatarView!.tag = uid.toInt()!
        self.lastdate.setWidth(lastdate.stringWidthWith(11, height: 21))
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as! String
        var safeshell = Sa.objectForKey("shell") as! String
        if uid == safeuid {
            layoutWord(height, content: content, user: user, lastdate: lastdate, isMe: true)
        }else{
            layoutWord(height, content: content, user: user, lastdate: lastdate, isMe: false)
        }
    }
    
    func layoutWord(height: CGFloat, content: String, user: String, lastdate: String, isMe: Bool = false) {
        self.contentLabel!.setHeight(height)
        self.contentLabel.setY(25)
        self.contentLabel!.text = content
        if height == "".stringHeightWith(15,width:208) {      //如果是单行
            var oneLineWidth = content.stringWidthWith(15, height: 24)
            self.textContent.setWidth(oneLineWidth + 27)
            self.textContent.setHeight(37)
            self.contentLabelWidth = content.stringWidthWith(15, height: 24)
        }else{      //如果是多行
            self.textContent.setHeight(height+20)
            self.textContent.setWidth(235)
            self.contentLabelWidth = 208
        }
        if isMe {
            self.textContent.image = UIImage(named: "bubble_me")
            self.contentLabel.textColor = UIColor.blackColor()
            self.textContent.setX( globalWidth - 65 - self.textContent.width())
            self.avatarView.setX(globalWidth - 15 - 40)
            self.nickLabel.hidden = true
            self.lastdate.setX(globalWidth - 75 - lastdate.stringWidthWith(11, height: 21))
            self.contentLabel.setX(globalWidth - 80 - self.contentLabelWidth)
        }else{
            self.textContent.image = UIImage(named: "bubble")
            self.contentLabel.textColor = UIColor.whiteColor()
            self.textContent.setX(65)
            self.avatarView.setX(15)
            self.nickLabel.hidden = false
            self.nickLabel.setBottom(height + 60)
            self.nickLabel.setWidth(user.stringWidthWith(11, height: 21))
            self.lastdate.setX(user.stringWidthWith(11, height: 21)+83)
            self.contentLabel.setX(80)
        }
        self.avatarView.setBottom(height + 55)
        self.lastdate.setBottom(height + 60)
    }
    
    class func cellHeightByData(data:NSDictionary)->CGFloat {
        var content = data.stringAttributeForKey("content")
        var type = data.stringAttributeForKey("type")
        var cid = data.stringAttributeForKey("cid")
        var height = content.stringHeightWith(15,width:208)
        return height + 60
    }
    
}







