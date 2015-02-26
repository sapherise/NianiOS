//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class DreamCell: UITableViewCell {
    @IBOutlet var avatarView:UIImageView?
    @IBOutlet var nickLabel:UILabel?
    @IBOutlet var contentLabel:UILabel?
    @IBOutlet var lastdate:UILabel?
    @IBOutlet var imageholder:UIImageView?
    @IBOutlet var View:UIView?
    @IBOutlet var menuHolder:UIView?
    @IBOutlet weak var like: UILabel!
    @IBOutlet weak var share: UIButton!
    @IBOutlet weak var likebutton:UIButton!
    @IBOutlet weak var liked:UIButton!
    @IBOutlet var labelComment:UILabel!
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
        self.share.addTarget(self, action: "SAshare", forControlEvents: UIControlEvents.TouchUpInside)
        self.setWidth(globalWidth)
        self.menuHolder?.setWidth(globalWidth)
        self.viewLine.setWidth(globalWidth)
        self.likebutton.setX(globalWidth-50)
        self.liked.setX(globalWidth-50)
        self.share.setX(globalWidth-50)
        self.contentLabel?.setWidth(globalWidth-30)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var sid = self.data.stringAttributeForKey("sid")
        self.sid = sid.toInt()!
        var uid = self.data.stringAttributeForKey("uid")
        var user = self.data.stringAttributeForKey("user")
        var lastdate = self.data.stringAttributeForKey("lastdate")
        var liked = self.data.stringAttributeForKey("liked")
        content = self.data.stringAttributeForKey("content")
        img = self.data.stringAttributeForKey("img") as NSString
        img0 = (self.data.stringAttributeForKey("img0") as NSString).floatValue
        img1 = (self.data.stringAttributeForKey("img1") as NSString).floatValue
        var like = self.data.stringAttributeForKey("like") as String
        var comment = self.data.stringAttributeForKey("comment")
        
        self.nickLabel!.text = user
        self.lastdate!.text = lastdate
        
        var userImageURL = "http://img.nian.so/head/\(uid).jpg!dream"
        self.avatarView!.setImage(userImageURL,placeHolder: IconColor)
        self.avatarView!.tag = uid.toInt()!
        self.nickLabel!.tag = uid.toInt()!
        
        self.like!.tag = sid.toInt()!
        
        var height = content.stringHeightWith(16,width:globalWidth-30)
        
        if content == "" {
            height = 0
        }
        self.contentLabel!.setHeight(height)
        self.contentLabel!.text = content
        self.share.tag = sid.toInt()!
        self.labelComment.tag = sid.toInt()!
        if comment != "0" {
            comment = "\(comment) 评论"
        }else{
            comment = "评论"
        }
        if like == "0" {
            self.like.hidden = true
        }else{
            self.like.hidden = false
        }
        like = "\(like) 赞"
        self.like.text = like
        var likeWidth = like.stringWidthWith(13, height: 30) + 17
        self.like.setWidth(likeWidth)
        self.labelComment.text = comment
        var commentWidth = comment.stringWidthWith(13, height: 30) + 17
        self.labelComment.setWidth(commentWidth)
        self.like.setX(commentWidth+23)
        
        if img0 == 0.0 {
            self.imageholder!.hidden = true
            imgHeight = 0
            self.contentLabel!.setY(70)
        }else{
            imgHeight = img1 * Float(globalWidth) / img0
            ImageURL = "http://img.nian.so/step/\(img)!large" as NSString
            largeImageURL = "http://img.nian.so/step/\(img)!large" as NSString
            self.imageholder!.setImage(ImageURL,placeHolder: IconColor)
            self.imageholder!.setWidth(globalWidth)
            self.imageholder!.setHeight(CGFloat(imgHeight))
            var sapherise = self.imageholder!.frame.size.height
            self.imageholder!.hidden = false
            self.contentLabel!.setY(self.imageholder!.bottom()+15)
        }
        if content == "" {
            self.menuHolder!.setY(self.contentLabel!.bottom()-5)
        }else{
            self.menuHolder!.setY(self.contentLabel!.bottom()+5)
        }
        self.viewLine.setY(self.menuHolder!.bottom()+10)
        
        
        //主人
        var Sa = NSUserDefaults.standardUserDefaults()
        var cookieuid: String = Sa.objectForKey("uid") as String
        
        if cookieuid == uid {
            self.likebutton!.hidden = true
            self.liked!.hidden = true
        }else{
            self.share!.setX(globalWidth-90)
            if liked == "0" {
                self.likebutton!.hidden = false
                self.liked!.hidden = true
            }else{
                self.likebutton!.hidden = true
                self.liked!.hidden = false
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
    
    class func cellHeightByData(data:NSDictionary)->CGFloat
    {
        var content = data.stringAttributeForKey("content")
        var img0 = (data.stringAttributeForKey("img0") as NSString).floatValue
        var img1 = (data.stringAttributeForKey("img1") as NSString).floatValue
        var height = content.stringHeightWith(16,width:globalWidth-30)
        if(img0 == 0.0){
            if content == "" {
                return 136
            }else{
                return height + 151
            }
        }else{
            if content == "" {
                return 156 + CGFloat(img1*Float(globalWidth)/img0)
            }else{
                return height + 171 + CGFloat(img1*Float(globalWidth)/img0)
            }
        }
    }
    
    
}
