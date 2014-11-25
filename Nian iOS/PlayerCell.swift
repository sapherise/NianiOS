//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class PlayerCell: UITableViewCell {
    @IBOutlet var avatarView:UIImageView?
    @IBOutlet var nickLabel:UILabel?
    @IBOutlet var contentLabel:UILabel?
    @IBOutlet var lastdate:UILabel?
    @IBOutlet var imageholder:UIImageView?
    @IBOutlet var View:UIView?
    @IBOutlet var menuHolder:UIView?
    @IBOutlet weak var like: UILabel!
    @IBOutlet weak var share: UIButton!
    @IBOutlet weak var goodbye: UIButton!
    @IBOutlet weak var edit: UIButton!
    @IBOutlet weak var likebutton:UIButton!
    @IBOutlet weak var liked:UIButton!
    @IBOutlet var labelComment:UILabel!
    var largeImageURL:String = ""
    var data :NSDictionary!
    var imgHeight:Float = 0.0
    var content:String = ""
    var img:String = ""
    var img0:Float = 0.0
    var img1:Float = 0.0
    var ImageURL:String = ""
    var indexPathRow:Int = 0
    
    @IBAction func nolikeClick(sender: AnyObject) { //取消赞
        self.liked!.hidden = true
        self.likebutton!.hidden = false
        var likenumber = SAReplace(self.like!.text!, " 赞", "") as String
        var likenewnumber = likenumber.toInt()! - 1
        self.like!.text = "\(likenewnumber) 赞"
        self.data.setValue("\(likenewnumber)", forKey: "like")
        if likenewnumber == 0 {
            self.like!.hidden = true
        }else{
            self.like!.hidden = false
        }
        self.data.setValue("0", forKey: "liked")
        var sid = self.data.stringAttributeForKey("sid")
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var sa = SAPost("step=\(sid)&&uid=\(safeuid)&&shell=\(safeshell)&&like=0", "http://nian.so/api/like_query.php")
            if sa == "1" {
            }
        })
    }
    @IBAction func likeClick(sender: AnyObject) {   //赞
        self.likebutton!.hidden = true
        self.liked!.hidden = false
        var likenumber = SAReplace(self.like!.text!, " 赞", "") as String
        var likenewnumber = likenumber.toInt()! + 1
        self.like!.text = "\(likenewnumber) 赞"
        self.data.setValue("\(likenewnumber)", forKey: "like")
        self.data.setValue("1", forKey: "liked")
        self.like!.hidden = false
        
        var sid = self.data.stringAttributeForKey("sid")
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var sa = SAPost("step=\(sid)&&uid=\(safeuid)&&shell=\(safeshell)&&like=1", "http://nian.so/api/like_query.php")
            if sa == "1" {
            }
        })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.share.addTarget(self, action: "SAshare", forControlEvents: UIControlEvents.TouchUpInside)
        var tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DreamimageViewTapped:")
        self.imageholder!.addGestureRecognizer(tap)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        var sid = self.data.stringAttributeForKey("sid")
        var uid = self.data.stringAttributeForKey("uid")
        var user = self.data.stringAttributeForKey("user")
        var lastdate = self.data.stringAttributeForKey("lastdate")
        var liked = self.data.stringAttributeForKey("liked")
        content = self.data.stringAttributeForKey("content")
        img = self.data.stringAttributeForKey("img") as NSString
        img0 = (self.data.stringAttributeForKey("img0") as NSString).floatValue
        img1 = (self.data.stringAttributeForKey("img1") as NSString).floatValue
        var like = self.data.stringAttributeForKey("like") as String
        var comment = self.data.stringAttributeForKey("comment") as String
        var dreamtitle = self.data.stringAttributeForKey("dreamtitle") as String
        
        self.nickLabel!.text = user
        self.lastdate!.text = "\(dreamtitle)，\(lastdate)"
        
        var userImageURL = "http://img.nian.so/head/\(uid).jpg!dream"
        self.avatarView!.setImage(userImageURL,placeHolder: IconColor)
        self.avatarView!.tag = uid.toInt()!
        self.nickLabel!.tag = uid.toInt()!
        
        self.like!.tag = sid.toInt()!
        
        var height = content.stringHeightWith(17,width:290)
        self.contentLabel!.setHeight(height)
        self.contentLabel!.text = content
        self.goodbye.tag = sid.toInt()!
        self.edit.tag = self.indexPathRow
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
            //      self.holder!.setHeight(height+136)
            imgHeight = 0
            self.contentLabel!.setY(70)
            self.menuHolder!.setY(self.contentLabel!.bottom()+5)
        }else{
            imgHeight = img1 * 320 / img0
            ImageURL = "http://img.nian.so/step/\(img)!large" as NSString
            largeImageURL = "http://img.nian.so/step/\(img)!large" as NSString
            self.imageholder!.setImage(ImageURL,placeHolder: IconColor)
            self.imageholder!.setHeight(CGFloat(imgHeight))
            var sapherise = self.imageholder!.frame.size.height
            self.imageholder!.hidden = false
            //      self.holder!.setHeight(height+156+sapherise)
            
            self.contentLabel!.setY(self.imageholder!.bottom()+15)
            self.menuHolder!.setY(self.contentLabel!.bottom()+5)
        }
        
        
        
        //主人
        var Sa = NSUserDefaults.standardUserDefaults()
        var cookieuid: String = Sa.objectForKey("uid") as String
        
        if cookieuid == uid {
            self.likebutton!.hidden = true
            self.liked!.hidden = true
        }else{
            self.goodbye!.hidden = true
            self.edit!.hidden = true
            self.share!.setX(230)
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
            NSNotificationCenter.defaultCenter().postNotificationName("ShareContent", object:[ content, "" ])
        }else{
            NSNotificationCenter.defaultCenter().postNotificationName("ShareContent", object:[ content, ImageURL ])
        }
    }
    func DreamimageViewTapped(sender:UITapGestureRecognizer){
        NSNotificationCenter.defaultCenter().postNotificationName("DreamimageViewTapped", object:largeImageURL)
    }
    
    class func cellHeightByData(data:NSDictionary)->CGFloat
    {
        var content = data.stringAttributeForKey("content")
        var img0 = (data.stringAttributeForKey("img0") as NSString).floatValue
        var img1 = (data.stringAttributeForKey("img1") as NSString).floatValue
        var height = content.stringHeightWith(17,width:290)
        if(img0 == 0.0){
            return height + 151
        }else{
            return height + 171 + CGFloat(img1*320/img0)
        }
    }
    
    
}
