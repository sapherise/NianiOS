//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class FollowCell: UITableViewCell {
    
    @IBOutlet var avatarView:UIImageView?
    @IBOutlet var nickLabel:UILabel?
    @IBOutlet var contentLabel:UILabel?
    @IBOutlet var holder:UILabel?
    @IBOutlet var lastdate:UILabel?
    @IBOutlet var imageholder:UIImageView?
    @IBOutlet var View:UIView?
    @IBOutlet var likebutton:UIButton?
    @IBOutlet var likedbutton:UIButton?
    @IBOutlet var like:UILabel?
    @IBOutlet var menuHolder:UIView?
    @IBOutlet var share:UIButton?
    var LargeImgURL:String = ""
    var data :NSDictionary!
    var user:String = ""
    
    @IBAction func nolikeClick(sender: AnyObject) { //取消赞
        self.likedbutton!.hidden = true
        self.likebutton!.hidden = false
        if self.like!.text == "" {
            self.like!.text = "0 赞"
            self.data.setValue("0", forKey: "like")
            self.like!.hidden = true
        }else{
            var likenumber = SAReplace(self.like!.text, " 赞", "") as String
            var likenewnumber = likenumber.toInt()! - 1
            self.like!.text = "\(likenewnumber) 赞"
            self.data.setValue("\(likenewnumber)", forKey: "like")
            if likenewnumber == 0 {
                self.like!.hidden = true
            }else{
                self.like!.hidden = false
            }
        }
        self.data.setValue("0", forKey: "liked")
        var sid = self.data.stringAttributeForKey("sid")
        var sa = SAPost("step=\(sid)&&uid=1&&like=0", "http://nian.so/api/like_query.php")
        if sa == "1" {
        }
    }
    @IBAction func likeClick(sender: AnyObject) {   //赞
        self.likebutton!.hidden = true
        self.likedbutton!.hidden = false
        if self.like!.text == "" {
            self.like!.text = "1 赞"
            self.data.setValue("1", forKey: "like")
        }else{
            var likenumber = SAReplace(self.like!.text, " 赞", "") as String
            var likenewnumber = likenumber.toInt()! + 1
            self.like!.text = "\(likenewnumber) 赞"
            self.data.setValue("\(likenewnumber)", forKey: "like")
        }
        self.data.setValue("1", forKey: "liked")
        self.like!.hidden = false        
        var sid = self.data.stringAttributeForKey("sid")
        var sa = SAPost("step=\(sid)&&uid=1&&like=1", "http://nian.so/api/like_query.php")
       if sa == "1" {
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .None
        
        
        var tap = UITapGestureRecognizer(target: self, action: "imageViewTapped:")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews()
    {
        
        
        super.layoutSubviews()
        var uid = self.data.stringAttributeForKey("uid")
        var sid = self.data.stringAttributeForKey("sid")
        user = self.data.stringAttributeForKey("user")
        var lastdate = self.data.stringAttributeForKey("lastdate")
        var content = self.data.stringAttributeForKey("content")
        var like = self.data.stringAttributeForKey("like")
        var liked = self.data.stringAttributeForKey("liked")
        var img = self.data.stringAttributeForKey("img") as NSString
        var img0 = (self.data.stringAttributeForKey("img0") as NSString).floatValue
        var img1 = (self.data.stringAttributeForKey("img1") as NSString).floatValue
        
        self.nickLabel!.text = user
        self.lastdate!.text = lastdate
        self.View!.backgroundColor = BGColor
        
        var userImageURL = "http://img.nian.so/head/\(uid).jpg!head"
        self.avatarView!.setImage(userImageURL,placeHolder: UIImage(named: "1.jpg"))
        self.avatarView!.userInteractionEnabled = true
        self.avatarView!.tag = uid.toInt()!
        
        var height = content.stringHeightWith(17,width:280)
        
        
        
        self.contentLabel!.setHeight(height)
        self.contentLabel!.text = content
        self.holder!.layer.cornerRadius = 4;
        self.holder!.layer.masksToBounds = true;
//        self.holder!.layer.borderColor = BorderColor.CGColor
//        self.holder!.layer.borderWidth = 1
        
        if img0 == 0.0 {
            self.imageholder!.hidden = true
            self.holder!.setHeight(height+136)
            var imgHeight:Float = 0.0
            self.menuHolder!.setY(self.contentLabel!.bottom())
        }else{
            var imgHeight:Float = img1 * 250 / img0
            var ImageURL = "http://img.nian.so/step/\(img)!iosfo" as NSString
            LargeImgURL = "http://img.nian.so/step/\(img)!large" as NSString
            self.imageholder!.setImage(ImageURL,placeHolder: UIImage(named: "1.jpg"))
            self.imageholder!.setHeight(CGFloat(imgHeight))
            self.imageholder!.hidden = false
            self.holder!.setHeight(height+156+self.imageholder!.frame.size.height)
            var tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "imageViewTapped:")
            self.imageholder!.addGestureRecognizer(tap)
            self.imageholder!.userInteractionEnabled = true
            self.imageholder!.setY(self.contentLabel!.bottom()+10)
            self.menuHolder!.setY(self.imageholder!.bottom()+10)
        }
        
        if like == "0" {
            self.like!.hidden = true
        }else{
            self.like!.hidden = false
            self.like!.text = "\(like) 赞"
        }
        
        if liked == "0" {
            self.likebutton!.hidden = false
            self.likedbutton!.hidden = true
        }else{
            self.likebutton!.hidden = true
            self.likedbutton!.hidden = false
        }
        
        self.like!.userInteractionEnabled = true
        self.like!.tag = sid.toInt()!
        self.share!.addTarget(self, action: "SAshare", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func imageViewTapped(sender:UITapGestureRecognizer){
        NSNotificationCenter.defaultCenter().postNotificationName("imageViewTapped", object:LargeImgURL)
    }
    func SAshare(){
        var img0 = (self.data.stringAttributeForKey("img0") as NSString).floatValue
        var content = self.data.stringAttributeForKey("content") as NSString
        var img = self.data.stringAttributeForKey("img") as NSString
        var ImageURL = "http://img.nian.so/step/\(img)!iosfo" as NSString
        if img0 == 0.0 {
            NSNotificationCenter.defaultCenter().postNotificationName("ShareContent", object:[ content, "" ])
        }else{
            NSNotificationCenter.defaultCenter().postNotificationName("ShareContent", object:[ content, ImageURL ])
        }
    }
    
    
    
    class func cellHeightByData(data:NSDictionary)->CGFloat
    {
        var content = data.stringAttributeForKey("content")
        var img0 = (data.stringAttributeForKey("img0") as NSString).floatValue
        var img1 = (data.stringAttributeForKey("img1") as NSString).floatValue
        var height = content.stringHeightWith(17,width:280)
        if img1 == 0.0 {
            return height + 151
        }else{
            return height + 171 + CGFloat(img1*250/img0)
        }
    }
    
}
