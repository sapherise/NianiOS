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
    @IBOutlet var imageDream: UIImageView!
    @IBOutlet var labelDream: UILabel!
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
        self.setWidth(globalWidth)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var uid = self.data.stringAttributeForKey("uid")
        var user = self.data.stringAttributeForKey("user")
        var lastdate = self.data.stringAttributeForKey("lastdate")
        var content = self.data.stringAttributeForKey("content")
        var cid = self.data.stringAttributeForKey("cid")
        var type = (self.data.objectForKey("type") as String).toInt()!
        self.nickLabel!.text = user
        self.lastdate!.text = lastdate
        var userImageURL = "http://img.nian.so/head/\(uid).jpg!dream"
        self.avatarView!.setImage(userImageURL,placeHolder: IconColor)
        var height = content.stringHeightWith(15,width:208)
        self.avatarView!.tag = uid.toInt()!
        self.lastdate.setWidth(lastdate.stringWidthWith(11, height: 21))
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        if uid == safeuid {
            if type == 1 {      // 自己的文字
                layoutWord(height, content: content, user: user, lastdate: lastdate, isMe: true)
            }else if type == 2 {        // 自己的图片
                // sapherise
                layoutImage(height, content: content, user: user, lastdate: lastdate, isMe: true)
            }else if type == 3 {    // 自己的梦想
                let (resultDes, err) = SD.executeQuery("select * from step where sid = '\(cid)' limit 1")
                if resultDes.count > 0 {
                    for row in resultDes {
                        var img = (row["img"]?.asString())!
                        var img0 = (row["img0"]?.asString())!
                        var img1 = (row["img1"]?.asString())!
                        var contentStep = (row["content"]?.asString())!
                        height = contentStep.stringHeightWith(15, width: 208) + 128
                        layoutDream(height, contentStep: contentStep, img: img, img0: img0, img1: img1, user: user, title: content, lastdate: lastdate, isMe: true)
                        break
                    }
                } else {
                    Api.getSingleStep(cid) { json in
                        if json != nil {
                            if let item = json!["items"] as? NSArray {
                                var data = item[0] as NSDictionary
                                var sid = data.stringAttributeForKey("sid")
                                var uid = data.stringAttributeForKey("uid")
                                var dream = data.stringAttributeForKey("dream")
                                var contentStep = data.stringAttributeForKey("content")
                                var img = data.stringAttributeForKey("img")
                                var img0 = data.stringAttributeForKey("img0")
                                var img1 = data.stringAttributeForKey("img1")
                                SQLStepContent(sid, uid, dream, content, img, img0, img1) {
                                    self.layoutDream(height, contentStep: contentStep, img: img, img0: img0, img1: img1, user: user, title: content, lastdate: lastdate, isMe: true)
                                }
                            }
                        }
                    }
                }
            }
        }else{
            if type == 1 {      // 别人的文字
                layoutWord(height, content: content, user: user, lastdate: lastdate, isMe: false)
            }else if type == 2 {     // 别人的图片
                layoutImage(height, content: content, user: user, lastdate: lastdate, isMe: false)
            }else if type == 3 {    // 别人的梦想
                let (resultDes, err) = SD.executeQuery("select * from step where sid = '\(cid)' limit 1")
                if resultDes.count > 0 {
                    for row in resultDes {
                        var img = (row["img"]?.asString())!
                        var img0 = (row["img0"]?.asString())!
                        var img1 = (row["img1"]?.asString())!
                        var contentStep = (row["content"]?.asString())!
                        height = contentStep.stringHeightWith(15, width: 208) + 128
                        layoutDream(height, contentStep: contentStep, img: img, img0: img0, img1: img1, user: user, title: content, lastdate: lastdate, isMe: false)
                        break
                    }
                } else {
                    Api.getSingleStep(cid) { json in
                        if json != nil {
                            if let item = json!["items"] as? NSArray {
                                var data = item[0] as NSDictionary
                                var sid = data.stringAttributeForKey("sid")
                                var uid = data.stringAttributeForKey("uid")
                                var dream = data.stringAttributeForKey("dream")
                                var contentStep = data.stringAttributeForKey("content")
                                var img = data.stringAttributeForKey("img")
                                var img0 = data.stringAttributeForKey("img0")
                                var img1 = data.stringAttributeForKey("img1")
                                SQLStepContent(sid, uid, dream, content, img, img0, img1) {
                                    self.layoutDream(height, contentStep: contentStep, img: img, img0: img0, img1: img1, user: user, title: content, lastdate: lastdate, isMe: false)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func layoutWord(height: CGFloat, content: String, user: String, lastdate: String, isMe: Bool = false) {
        self.textContent.hidden = false
        self.contentLabel.hidden = false
        self.imageContent.hidden = true
        self.imageDream.hidden = true
        self.labelDream.hidden = true
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
    
    func layoutImage(height: CGFloat, content: String, user: String, lastdate: String, isMe: Bool = false) {
        self.textContent.hidden = true
        self.contentLabel.hidden = true
        self.imageContent.hidden = false
        self.imageDream.hidden = true
        self.labelDream.hidden = true
        var arrContent = content.componentsSeparatedByString("_")
        if arrContent.count == 4 {
            if let n = NSNumberFormatter().numberFromString(arrContent[3]) {
                var width = CGFloat(NSNumberFormatter().numberFromString(arrContent[2])!)
                var imageHeight = CGFloat(n)
                self.imageContent.frame = CGRectMake(0, 15, width, imageHeight)
                var url = "http://img.nian.so/circle/\(arrContent[0])_\(arrContent[1]).png!a"
                if arrContent[1] == "loading" {
                    self.activity = UIActivityIndicatorView()
                    self.activity!.color = UIColor.whiteColor()
                    self.activity!.transform = CGAffineTransformMakeScale(0.7, 0.7)
                    self.activity!.startAnimating()
                    self.activity!.hidden = false
                    self.imageContent.image = SAColorImg(SeaColor)
                    self.addSubview(activity!)
                }else{
                    self.imageContent.setImage(url, placeHolder: SeaColor, bool: false)
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
                self.imageContent.SAMaskImage(isMe: isMe)
                self.avatarView.setBottom(imageHeight + 35)
                self.lastdate.setBottom(imageHeight + 40)
            }
        }
    }
    
    func layoutDream(height: CGFloat, contentStep: String, img: String, img0: String, img1: String, user: String, title: String, lastdate: String, isMe: Bool) {
        self.textContent.hidden = false
        self.contentLabel.hidden = false
        self.imageContent.hidden = true
        self.textContent.setWidth(235)
        self.imageDream.hidden = false
        let maskPath = UIBezierPath(roundedRect: self.imageDream.bounds, byRoundingCorners: ( UIRectCorner.TopLeft | UIRectCorner.TopRight ), cornerRadii: CGSizeMake(6, 6))
        var maskLayer = CAShapeLayer()
        maskLayer.frame = self.imageDream.bounds
        maskLayer.path = maskPath.CGPath
        self.imageDream.layer.mask = maskLayer
        if img0.toInt() != 0 || img1.toInt() != 0 {
            // 进展配图
            self.imageDream.setImage("http://img.nian.so/step/\(img)!b", placeHolder: SeaColor)
        }else{
            // 封面配图
            self.imageDream.setImage("http://img.nian.so/dream/\(img)!b", placeHolder: SeaColor)
        }
        self.textContent.setHeight(height+20)
        self.nickLabel.setBottom(height + 60)
        self.nickLabel.setWidth(user.stringWidthWith(11, height: 21))
        var w = title.stringWidthWith(11, height: 21)+12
        w = w > 110 ? 110 : w
        self.labelDream.setWidth(w)
        self.labelDream.setX(80)
        self.labelDream.text = title
        var maskLayer2 = CAShapeLayer()
        maskLayer2.frame = self.labelDream.bounds
        maskLayer2.path = UIBezierPath(roundedRect: self.labelDream.bounds, byRoundingCorners: ( UIRectCorner.BottomLeft | UIRectCorner.BottomRight ), cornerRadii: CGSizeMake(4, 4)).CGPath
        self.labelDream.layer.mask = maskLayer2
        self.contentLabel!.text = contentStep
        
        self.avatarView.setBottom(height + 55)
        self.lastdate.setBottom(height + 60)
        if isMe {
            self.textContent.image = UIImage(named: "bubble_me")
            self.contentLabel.textColor = UIColor.blackColor()
            self.textContent.setX( globalWidth - 65 - self.textContent.width())
            self.avatarView.setX(globalWidth - 15 - 40)
            self.nickLabel.hidden = true
            self.lastdate.setX(globalWidth - 75 - lastdate.stringWidthWith(11, height: 21))
            self.contentLabel.frame = CGRectMake(globalWidth - 80 - self.contentLabelWidth, 153, 208, height - 128)
            self.imageDream.setX(globalWidth - 300)
            self.labelDream.setX(globalWidth - 300 + 15)
            self.contentLabel.setX(globalWidth - 300 + 15)
        }else{
            self.textContent.image = UIImage(named: "bubble")
            self.contentLabel.textColor = UIColor.whiteColor()
            self.textContent.setX(65)
            self.avatarView.setX(15)
            self.nickLabel.hidden = false
            self.lastdate.setX(user.stringWidthWith(11, height: 21)+83)
            self.contentLabel.frame = CGRectMake(80, 153, 208, height - 128)
            self.imageDream.setX(65)
            self.labelDream.setX(80)
            self.contentLabel.setX(80)
        }
    }
    
    class func cellHeightByData(data:NSDictionary, isImage:Int = 0)->CGFloat {
        var content = data.stringAttributeForKey("content")
        var type = data.stringAttributeForKey("type")
        var cid = data.stringAttributeForKey("cid")
        if type != "3" {
            if isImage == 0 {
                var height = content.stringHeightWith(15,width:208)
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
        }else{
            let (resultDes, err) = SD.executeQuery("select * from step where sid = '\(cid)' limit 1")
            if resultDes.count > 0 {
                for row in resultDes {
                    var contentStep = (row["content"]?.asString())!
                    var height = contentStep.stringHeightWith(15,width:208)
                    return height + 60 + 138
                }
            }
        }
        return 100
    }
    
}







