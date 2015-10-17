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


class CircleImageCell: UITableViewCell {
    
    @IBOutlet var avatarView:UIImageView!
    @IBOutlet var nickLabel:UILabel!
    @IBOutlet var lastdate:UILabel!
    @IBOutlet var View:UIView!
    @IBOutlet var imageContent:UIImageView!
    var activity: UIActivityIndicatorView?
    var data :NSDictionary!
    var contentLabelWidth:CGFloat = 0
    
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
        if data != nil {
            let uid = self.data.stringAttributeForKey("uid")
            let user = self.data.stringAttributeForKey("user")
            let lastdate = self.data.stringAttributeForKey("lastdate")
            let content = self.data.stringAttributeForKey("content")
            self.nickLabel!.text = user
            self.lastdate!.text = lastdate
            self.avatarView.setHead(uid)
            let height = content.stringHeightWith(15,width:208)
            self.avatarView!.tag = Int(uid)!
            self.lastdate.setWidth(lastdate.stringWidthWith(11, height: 21))
            
            let safeuid = SAUid()
            if uid == safeuid {
                layoutImage(height, content: content, user: user, lastdate: lastdate, isMe: true)
            }else{
                layoutImage(height, content: content, user: user, lastdate: lastdate, isMe: false)
            }
        }
    }
    
    func layoutImage(height: CGFloat, content: String, user: String, lastdate: String, isMe: Bool = false) {
        var arrContent = content.componentsSeparatedByString("_")
        if arrContent.count == 4 {
            if let n = NSNumberFormatter().numberFromString(arrContent[3]) {
                let width = CGFloat(NSNumberFormatter().numberFromString(arrContent[2])!)
                let imageHeight = CGFloat(n)
                self.imageContent.frame = CGRectMake(0, 15, width, imageHeight)
                let url = "http://img.nian.so/circle/\(arrContent[0])_\(arrContent[1]).png!a"
                if arrContent[1] == "loading" {
                    self.activity = UIActivityIndicatorView()
                    self.activity!.color = UIColor.whiteColor()
                    self.activity!.transform = CGAffineTransformMakeScale(0.7, 0.7)
                    self.activity!.startAnimating()
                    self.activity!.hidden = false
                    self.imageContent.image = SAColorImg(SeaColor)
                    self.addSubview(activity!)
                }else{
                    // todo: 原来背景颜色是蓝色的
                    self.imageContent.setImage(url)
                    self.activity?.removeFromSuperview()
                }
                if isMe {
                    self.imageContent.setX( globalWidth - 65 - self.imageContent.width())
                    self.avatarView.setX(globalWidth - 15 - 40)
                    self.nickLabel.hidden = true
                    self.lastdate.setX(globalWidth - 75 - lastdate.stringWidthWith(11, height: 21))
                    if let a = self.activity {
                        a.center = self.imageContent.center
                    }
                }else{
                    self.imageContent.setX(65)
                    self.avatarView.setX(15)
                    self.nickLabel.hidden = false
                    self.nickLabel.setBottom(imageHeight + 40)
                    self.nickLabel.setWidth(user.stringWidthWith(11, height: 21))
                    self.lastdate.setX(user.stringWidthWith(11, height: 21)+83)
                }
                self.imageContent.setHeight(imageHeight)
                self.imageContent.setWidth(width)
                self.imageContent.SAMaskImage(isMe)
                self.avatarView.setBottom(imageHeight + 35)
                self.lastdate.setBottom(imageHeight + 40)
            }
        }
    }
    
    class func cellHeightByData(data:NSDictionary)->CGFloat {
        let content = data.stringAttributeForKey("content")
        var arrContent = content.componentsSeparatedByString("_")
        if arrContent.count == 4 {
            if let n = NSNumberFormatter().numberFromString(arrContent[3]) {
                let height = CGFloat(n)
                return height + 40
            }
        }
        return 100
    }
    
}







