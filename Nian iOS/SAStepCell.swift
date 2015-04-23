//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class SAStepCell: UITableViewCell {
    
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var imageHolder: UIImageView!
    @IBOutlet var viewMenu: UIView!
    @IBOutlet var btnMore: UIButton!
    @IBOutlet var btnLike: UIButton!
    @IBOutlet var btnUnLike: UIButton!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var labelLike: UILabel!
    @IBOutlet var labelComment: UILabel!
    @IBOutlet var labelDream: UILabel!
    @IBOutlet var labelTime: UILabel!
    @IBOutlet var viewLine: UIView!
    var largeImageURL:String = ""
    var data :NSDictionary!
    var imgHeight:Float = 0.0
    var content:String = ""
    var img:String = ""
    var img0:Float = 0.0
    var img1:Float = 0.0
    var ImageURL:String = ""
    var indexPathRow:Int = 0
    var sid:Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.btnMore.addTarget(self, action: "SAshare", forControlEvents: UIControlEvents.TouchUpInside)
        self.viewMenu.setWidth(globalWidth)
        self.setWidth(globalWidth)
        self.labelTime.setX(globalWidth - 92 - 15)
        self.btnMore.setX(globalWidth - 50)
        self.btnLike.setX(globalWidth - 50)
        self.btnUnLike.setX(globalWidth - 50)
        self.viewLine.setWidth(globalWidth)
        self.labelContent.setWidth(globalWidth-30)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var sid = self.data.stringAttributeForKey("sid")
        if sid.toInt() != nil {
            self.sid = sid.toInt()!
            var uid = self.data.stringAttributeForKey("uid")
            var user = self.data.stringAttributeForKey("user")
            var lastdate = self.data.stringAttributeForKey("lastdate") as String
            var liked = self.data.stringAttributeForKey("liked")
            content = self.data.stringAttributeForKey("content")
            img = self.data.stringAttributeForKey("img") as NSString as String
            img0 = (self.data.stringAttributeForKey("img0") as NSString).floatValue
            img1 = (self.data.stringAttributeForKey("img1") as NSString).floatValue
            var like = self.data.stringAttributeForKey("like") as String
            var comment = self.data.stringAttributeForKey("comment") as String
            var dreamtitle = self.data.stringAttributeForKey("dreamtitle") as String
            
            self.labelName.text = user
            self.labelTime.text = lastdate
            self.labelDream.text = dreamtitle
            self.imageHead.setHead(uid)
            self.imageHead.tag = uid.toInt()!
            self.labelName.tag = uid.toInt()!
            self.labelLike.tag = sid.toInt()!
            var height = content.stringHeightWith(16,width:globalWidth-30)
            if content == "" {
                height = 0
            }
            self.labelContent.setHeight(height)
            self.labelContent.text = content
            self.btnMore.tag = sid.toInt()!
            self.labelComment.tag = sid.toInt()!
            if comment != "0" {
                comment = "\(comment) 评论"
            }else{
                comment = "评论"
            }
            if like == "0" {
                self.labelLike.hidden = true
            }else{
                self.labelLike.hidden = false
            }
            like = "\(like) 赞"
            self.labelLike.text = like
            var likeWidth = like.stringWidthWith(13, height: 30) + 17
            self.labelLike.setWidth(likeWidth)
            self.labelComment.text = comment
            var commentWidth = comment.stringWidthWith(13, height: 30) + 17
            self.labelComment.setWidth(commentWidth)
            self.labelLike.setX(commentWidth+23)
            
            if img0 == 0.0 {
                if content == "" {  // 没有图片，没有文字
                    self.imageHolder.hidden = false
                    self.imageHolder.image = UIImage(named: "check")
                    self.imageHolder.frame.size = CGSizeMake(50, 23)
                    self.imageHolder.setX(15)
                }else{  // 没有图片，有文字
                    self.imageHolder.hidden = true
                    imgHeight = 0
                    self.labelContent.setY(70)
                }
            }else{
                imgHeight = img1 * Float(globalWidth) / img0
                ImageURL = "http://img.nian.so/step/\(img)!large" as NSString as String
                largeImageURL = "http://img.nian.so/step/\(img)!large" as NSString as String
                self.imageHolder.setImage(ImageURL,placeHolder: IconColor)
                self.imageHolder.setHeight(CGFloat(imgHeight))
                self.imageHolder.setWidth(globalWidth)
                self.imageHolder.hidden = false
                self.labelContent.setY(self.imageHolder.bottom()+15)
            }
            if content == "" {
                self.viewMenu.setY(self.imageHolder.bottom()+5)
            }else{
                self.viewMenu.setY(self.labelContent.bottom()+5)
            }
            self.viewLine.setY(self.viewMenu.bottom()+10)
            
            //主人
            var Sa = NSUserDefaults.standardUserDefaults()
            var cookieuid: String = Sa.objectForKey("uid") as! String
            if cookieuid == uid {
                self.btnLike.hidden = true
                self.btnUnLike.hidden = true
            }else{
                self.btnMore.setX(globalWidth - 90)
                if liked == "0" {
                    self.btnLike.hidden = false
                    self.btnUnLike.hidden = true
                }else{
                    self.btnLike.hidden = true
                    self.btnUnLike.hidden = false
                }
            }
        }
    }
    
    func SAshare(){
        if img0 == 0.0 {
            NSNotificationCenter.defaultCenter().postNotificationName("ShareContent", object:[ content, "", self.sid, self.indexPathRow + 10 ])
        }else{
            NSNotificationCenter.defaultCenter().postNotificationName("ShareContent", object:[ content, ImageURL, self.sid, self.indexPathRow + 10 ])
        }
    }
    
    class func cellHeightByData(data:NSDictionary)->CGFloat {
        var content = data.stringAttributeForKey("content")
        var img0 = (data.stringAttributeForKey("img0") as NSString).floatValue
        var img1 = (data.stringAttributeForKey("img1") as NSString).floatValue
        var height = content.stringHeightWith(16,width:globalWidth-30)
        if (img0 == 0.0) {
            var h = content == "" ? 179 : height + 151
            return h
        } else {
            var heightImage = CGFloat(img1 * Float(globalWidth) / img0)
            var h = content == "" ? 156 + heightImage : height + 171 + heightImage
            return h
        }
    }
}
