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


class CircleDreamCell: UITableViewCell {
    
    @IBOutlet var avatarView:UIImageView!
    @IBOutlet var nickLabel:UILabel!
    @IBOutlet var contentLabel:UILabel!
    @IBOutlet var lastdate:UILabel!
    @IBOutlet var View:UIView!
    @IBOutlet var textContent: UIImageView!
    @IBOutlet var imageDream: UIImageView!
    @IBOutlet var labelDream: UILabel!
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
        var uid = self.data.stringAttributeForKey("uid")
        var user = self.data.stringAttributeForKey("user")
        var lastdate = self.data.stringAttributeForKey("lastdate")
        var content = self.data.stringAttributeForKey("content")
        var cid = self.data.stringAttributeForKey("cid")
        var type = (self.data.objectForKey("type") as String).toInt()!
        self.nickLabel!.text = user
        self.lastdate!.text = lastdate
        self.avatarView.setHead(uid)
        var height = content.stringHeightWith(15,width:208)
        self.avatarView!.tag = uid.toInt()!
        self.lastdate.setWidth(lastdate.stringWidthWith(11, height: 21))
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        if uid == safeuid {
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
            }
        }else{
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
            }
        }
    }
    
    func layoutDream(height: CGFloat, contentStep: String, img: String, img0: String, img1: String, user: String, title: String, lastdate: String, isMe: Bool) {
        self.textContent.setWidth(235)
        let maskPath = UIBezierPath(roundedRect: self.imageDream.bounds, byRoundingCorners: ( UIRectCorner.TopLeft | UIRectCorner.TopRight ), cornerRadii: CGSizeMake(12, 12))
        var maskLayer = CAShapeLayer()
        maskLayer.frame = self.imageDream.bounds
        maskLayer.path = maskPath.CGPath
        self.imageDream.layer.mask = maskLayer
        self.imageDream.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).CGColor
        self.imageDream.layer.borderWidth = 0.5
        if img0.toInt() != 0 || img1.toInt() != 0 {
            // 进展配图
            self.imageDream.setImage("http://img.nian.so/step/\(img)!b", placeHolder: IconColor, bool: false)
        }else{
            // 封面配图
            self.imageDream.setImage("http://img.nian.so/dream/\(img)!b", placeHolder: IconColor, bool: false)
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
            self.contentLabel.frame = CGRectMake(globalWidth - 80 - self.contentLabelWidth, 151, 208, height - 127)
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
            self.contentLabel.frame = CGRectMake(80, 151, 208, height - 127)
            self.imageDream.setX(65)
            self.labelDream.setX(80)
            self.contentLabel.setX(80)
        }
    }
    
    class func cellHeightByData(data:NSDictionary)->CGFloat {
        var content = data.stringAttributeForKey("content")
        var type = data.stringAttributeForKey("type")
        var cid = data.stringAttributeForKey("cid")
        let (resultDes, err) = SD.executeQuery("select * from step where sid = '\(cid)' limit 1")
        if resultDes.count > 0 {
            for row in resultDes {
                var contentStep = (row["content"]?.asString())!
                var height = contentStep.stringHeightWith(15,width:208)
                return height + 60 + 138
            }
        }
        return 100
    }
    
}







