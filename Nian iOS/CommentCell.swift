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
    @IBOutlet var imageInner: UIImageView!
    var data :NSDictionary!
    var contentLabelWidth:CGFloat = 0
    var isImage:Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.nickLabel!.textColor = SeaColor
        self.avatarView.layer.masksToBounds = true
        self.avatarView.layer.cornerRadius = 20
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        var uid = self.data.stringAttributeForKey("uid")
        var user = self.data.stringAttributeForKey("user")
        var lastdate = self.data.stringAttributeForKey("lastdate")
        var content = self.data.stringAttributeForKey("content")
        
        self.nickLabel!.text = user
        self.lastdate!.text = lastdate
        
        var userImageURL = "http://img.nian.so/head/\(uid).jpg!dream"
        self.avatarView!.setImage(userImageURL,placeHolder: IconColor)
        
        var height = content.stringHeightWith(13,width:208)
        self.avatarView?.tag = uid.toInt()!
        if isImage == 0 {
            self.imageInner.hidden = true
            self.contentLabel!.setHeight(height)
            self.contentLabel!.text = content
            if floor(height) == 15.0 {      //如果是单行
                var oneLineWidth = content.stringWidthWith(13, height: 24)
                self.imageContent.setWidth(oneLineWidth + 27)
                self.imageContent.setHeight(37)
                self.contentLabelWidth = content.stringWidthWith(13, height: 24)
            }else{      //如果是多行
                self.imageContent.setHeight(height+20)
                self.imageContent.setWidth(235)
                self.contentLabelWidth = 208
            }
        }else{
            var arrContent = content.componentsSeparatedByString("_")
            if arrContent.count == 4 {
                if let n = NSNumberFormatter().numberFromString(arrContent[3]) {
                    var width = CGFloat(NSNumberFormatter().numberFromString(arrContent[2])!)
                    var url = "http://img.nian.so/circle/\(arrContent[0])_\(arrContent[1]).png!a"
                    var imageHeight = CGFloat(n)
                    height = imageHeight - 20
                    self.imageInner.hidden = false
                    self.imageInner.frame = CGRectMake(0, 0, width, imageHeight)
                    self.imageInner.setImage(url, placeHolder: IconColor)
                    self.imageInner.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImageTap:"))
                    self.contentLabel.hidden = true
                    self.contentLabel.text = ""
                    self.imageContent.setHeight(imageHeight)
                    self.imageContent.setWidth(width)
                }
            }
        }
        self.avatarView.setBottom(height + 55)
        self.nickLabel.setBottom(height + 60)
        self.nickLabel.setWidth(user.stringWidthWith(11, height: 21))
        self.lastdate.setWidth(lastdate.stringWidthWith(11, height: 21))
        self.lastdate.setBottom(height + 60)
        
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        if uid == safeuid {
            self.imageContent.image = UIImage(named: "bubble_me")
            self.contentLabel.textColor = UIColor.blackColor()
            self.imageContent.setX( globalWidth - 65 - self.imageContent.width())
            self.avatarView.setX(globalWidth - 15 - 40)
            self.nickLabel.hidden = true
            self.lastdate.setX(globalWidth - 75 - lastdate.stringWidthWith(11, height: 21))
            self.contentLabel.setX(globalWidth - 80 - self.contentLabelWidth)
            self.imageInner.SAMaskImage()
        }else{
            self.imageContent.image = UIImage(named: "bubble")
            self.contentLabel.textColor = UIColor.whiteColor()
            self.imageContent.setX(65)
            self.avatarView.setX(15)
            self.nickLabel.hidden = false
            self.lastdate.setX(user.stringWidthWith(11, height: 21)+83)
            self.contentLabel.setX(80)
            self.imageInner.SAMaskImage(isMe: false)
        }
        if isImage == 1 {
            self.imageInner.center = self.imageContent.center
        }
    }
    
    func onImageTap(sender:UITapGestureRecognizer) {
        var content = self.data.objectForKey("content") as String
        var arrContent = content.componentsSeparatedByString("_")
        if arrContent.count == 4 {
            var img0 = Float(NSNumberFormatter().numberFromString(arrContent[2])!)
            var img1 = Float(NSNumberFormatter().numberFromString(arrContent[3])!)
            if img0 != 0 {
                var newHeight = img1 * Float(globalWidth) / img0
                var url = "http://img.nian.so/circle/\(arrContent[0])_\(arrContent[1]).png!large"
                var yPoint = CGFloat((Float(globalHeight) - newHeight)/2)
                self.findRootViewController()?.view.showImage(url, width: Float(globalWidth), height: newHeight, yPoint: yPoint, bool:false)
            }
        }
    }
    
    class func cellHeightByData(data:NSDictionary, isImage:Int = 0)->CGFloat {
        var content = data.stringAttributeForKey("content")
        if isImage == 0 {
            var height = content.stringHeightWith(13,width:208)
            return height + 60
        }else{
            var arrContent = content.componentsSeparatedByString("_")
            if arrContent.count == 4 {
                if let n = NSNumberFormatter().numberFromString(arrContent[3]) {
                    var height = CGFloat(n)
                    return height + 40
                }
            }
        }
        return 100
    }
    
}







