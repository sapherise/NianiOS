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
    @IBOutlet var imageContent:UIImageView!
    @IBOutlet var textContent: UIImageView!
    var activity: UIActivityIndicatorView?
    var data :NSDictionary!
    var contentLabelWidth:CGFloat = 0
    var isImage:Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.nickLabel!.textColor = SeaColor
        self.avatarView.layer.masksToBounds = true
        self.avatarView.layer.cornerRadius = 20
        self.View.userInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var uid = self.data.stringAttributeForKey("uid")
        var user = self.data.stringAttributeForKey("user")
        var lastdate = self.data.stringAttributeForKey("lastdate")
        var content = self.data.stringAttributeForKey("content")
        var type = (self.data.objectForKey("type") as String).toInt()!
        self.nickLabel!.text = user
        self.lastdate!.text = lastdate
        var userImageURL = "http://img.nian.so/head/\(uid).jpg!dream"
        self.avatarView!.setImage(userImageURL,placeHolder: IconColor)
        var height = content.stringHeightWith(13,width:208)
        self.avatarView!.tag = uid.toInt()!
        self.lastdate.setWidth(lastdate.stringWidthWith(11, height: 21))
        self.textContent.setY(15)
        
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        if uid == safeuid {
            if type == 1 {      // 自己的文字
                self.textContent.hidden = false
                self.contentLabel.hidden = false
                self.imageContent.hidden = true
                self.contentLabel!.setHeight(height)
                self.contentLabel!.text = content
                if floor(height) == 15.0 {      //如果是单行
                    var oneLineWidth = content.stringWidthWith(13, height: 24)
                    self.textContent.setWidth(oneLineWidth + 27)
                    self.textContent.setHeight(37)
                    self.contentLabelWidth = content.stringWidthWith(13, height: 24)
                }else{      //如果是多行
                    self.textContent.setHeight(height+20)
                    self.textContent.setWidth(235)
                    self.contentLabelWidth = 208
                }
                self.textContent.image = UIImage(named: "bubble_me")
                self.contentLabel.textColor = UIColor.blackColor()
                self.textContent.setX( globalWidth - 65 - self.textContent.width())
                self.avatarView.setX(globalWidth - 15 - 40)
                self.nickLabel.hidden = true
                self.lastdate.setX(globalWidth - 75 - lastdate.stringWidthWith(11, height: 21))
                self.contentLabel.setX(globalWidth - 80 - self.contentLabelWidth)
            }else if type == 2 {        // 自己的图片
                self.textContent.hidden = true
                self.contentLabel.hidden = true
                self.imageContent.hidden = false
                var arrContent = content.componentsSeparatedByString("_")
                if arrContent.count == 4 {
                    if let n = NSNumberFormatter().numberFromString(arrContent[3]) {
                        var width = CGFloat(NSNumberFormatter().numberFromString(arrContent[2])!)
                        var imageHeight = CGFloat(n)
                        height = imageHeight - 20
                        self.imageContent.frame = CGRectMake(0, 15, width, imageHeight)
                        if arrContent[1] == "loading" {
                            self.activity = UIActivityIndicatorView()
                            self.activity!.color = UIColor.whiteColor()
                            self.activity!.transform = CGAffineTransformMakeScale(0.7, 0.7)
                            self.activity!.startAnimating()
                            self.activity!.hidden = false
                            self.imageContent.image = SAColorImg(SeaColor)
                            self.addSubview(activity!)
                        }else{
                            var url = "http://img.nian.so/circle/\(arrContent[0])_\(arrContent[1]).png!a"
                            self.imageContent.setImage(url, placeHolder: SeaColor, bool: false)
                            self.activity?.removeFromSuperview()
                        }
                        self.imageContent.setHeight(imageHeight)
                        self.imageContent.setWidth(width)
                    }
                }
                
                self.imageContent.setX( globalWidth - 65 - self.imageContent.width())
                self.avatarView.setX(globalWidth - 15 - 40)
                self.nickLabel.hidden = true
                self.lastdate.setX(globalWidth - 75 - lastdate.stringWidthWith(11, height: 21))
                self.imageContent.SAMaskImage()
                if let a = self.activity {
                    a.center = self.imageContent.center
                }
            }
        }else{
            if type == 1 {      // 别人的文字
                self.textContent.hidden = false
                self.contentLabel.hidden = false
                self.imageContent.hidden = true
                self.contentLabel!.setHeight(height)
                self.contentLabel!.text = content
                if floor(height) == 15.0 {      //如果是单行
                    var oneLineWidth = content.stringWidthWith(13, height: 24)
                    self.textContent.setWidth(oneLineWidth + 27)
                    self.textContent.setHeight(37)
                    self.contentLabelWidth = content.stringWidthWith(13, height: 24)
                }else{      //如果是多行
                    self.textContent.setHeight(height+20)
                    self.textContent.setWidth(235)
                    self.contentLabelWidth = 208
                }
                self.textContent.image = UIImage(named: "bubble")
                self.contentLabel.textColor = UIColor.whiteColor()
                self.textContent.setX(65)
                self.avatarView.setX(15)
                self.nickLabel.hidden = false
                self.nickLabel.setBottom(height + 60)
                self.nickLabel.setWidth(user.stringWidthWith(11, height: 21))
                self.lastdate.setX(user.stringWidthWith(11, height: 21)+83)
                self.contentLabel.setX(80)
            }else if type == 2{     // 别人的图片
                self.textContent.hidden = true
                self.contentLabel.hidden = true
                self.imageContent.hidden = false
                var arrContent = content.componentsSeparatedByString("_")
                if arrContent.count == 4 {
                    if let n = NSNumberFormatter().numberFromString(arrContent[3]) {
                        var width = CGFloat(NSNumberFormatter().numberFromString(arrContent[2])!)
                        var imageHeight = CGFloat(n)
                        height = imageHeight - 20
                        self.imageContent.frame = CGRectMake(0, 15, width, imageHeight)
                        var url = "http://img.nian.so/circle/\(arrContent[0])_\(arrContent[1]).png!a"
                        self.imageContent.setImage(url, placeHolder: SeaColor, bool: false)
                        self.activity?.removeFromSuperview()
                        self.imageContent.setHeight(imageHeight)
                        self.imageContent.setWidth(width)
                    }
                }
                self.imageContent.setX(65)
                self.avatarView.setX(15)
                self.nickLabel.hidden = false
                self.nickLabel.setBottom(height + 60)
                self.nickLabel.setWidth(user.stringWidthWith(11, height: 21))
                self.lastdate.setX(user.stringWidthWith(11, height: 21)+83)
                self.imageContent.SAMaskImage(isMe: false)
            }
        }
        self.avatarView.setBottom(height + 55)
        self.lastdate.setBottom(height + 60)
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







