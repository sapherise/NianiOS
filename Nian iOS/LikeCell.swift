//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class LikeCell: UITableViewCell {
    
    @IBOutlet var avatarView:UIImageView!
    @IBOutlet var nickLabel:UILabel!
    @IBOutlet var View:UIView!
    @IBOutlet var btnFollow:UIButton!
    var LargeImgURL:String = ""
    var data :NSDictionary!
    var user:String = ""
    var uid:String = ""
    var urlIdentify:Int = 0
    var circleID:String = "0"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.avatarView.layer.cornerRadius = 20
        self.avatarView.layer.masksToBounds = true
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.uid = self.data.stringAttributeForKey("uid") as String
        var follow = self.data.stringAttributeForKey("follow") as String
        user = self.data.stringAttributeForKey("user")
        self.nickLabel!.text = user
        var userImageURL = "http://img.nian.so/head/\(uid).jpg!dream"
        self.avatarView.tag = self.uid.toInt()!
        self.avatarView!.setImage(userImageURL,placeHolder: IconColor)
        
        if self.urlIdentify == 4 {
            self.btnFollow.layer.borderColor = SeaColor.CGColor
            self.btnFollow.layer.borderWidth = 1
            self.btnFollow.setTitleColor(SeaColor, forState: UIControlState.Normal)
            self.btnFollow.backgroundColor = UIColor.whiteColor()
            self.btnFollow.setTitle("邀请", forState: UIControlState.Normal)
            self.btnFollow.addTarget(self, action: "onInviteClick:", forControlEvents: UIControlEvents.TouchUpInside)
        }else{
            if follow == "0" {
                self.btnFollow.tag = 100
                self.btnFollow.layer.borderColor = SeaColor.CGColor
                self.btnFollow.layer.borderWidth = 1
                self.btnFollow.setTitleColor(SeaColor, forState: UIControlState.Normal)
                self.btnFollow.backgroundColor = UIColor.whiteColor()
                self.btnFollow.setTitle("关注", forState: UIControlState.Normal)
            }else{
                self.btnFollow.tag = 200
                self.btnFollow.layer.borderWidth = 0
                self.btnFollow.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                self.btnFollow.backgroundColor = SeaColor
                self.btnFollow.setTitle("关注中", forState: UIControlState.Normal)
            }
            self.btnFollow.addTarget(self, action: "onFollowClick:", forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    func onInviteClick(sender:UIButton){
        sender.layer.borderWidth = 0
        sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        sender.backgroundColor = SeaColor
        sender.setTitle("已邀请", forState: UIControlState.Normal)
        sender.removeTarget(self, action: "onInviteClick:", forControlEvents: UIControlEvents.TouchUpInside)
        Api.postCircleInvite(self.circleID, uid: self.uid) { json in
            if json != nil {
                globalWillCircleChatReload = 1
            }
        }
    }
    
    func onFollowClick(sender:UIButton){
        var tag = sender.tag
        if tag == 100 {     //没有关注
            self.data.setValue("1", forKey: "follow")
            sender.tag = 200
            sender.layer.borderWidth = 0
            sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            sender.backgroundColor = SeaColor
            sender.setTitle("关注中", forState: UIControlState.Normal)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var safeuid = Sa.objectForKey("uid") as String
                var safeshell = Sa.objectForKey("shell") as String
                var sa = SAPost("uid=\(self.uid)&&myuid=\(safeuid)&&shell=\(safeshell)&&fo=1", "http://nian.so/api/fo.php")
                if sa != "" && sa != "err" {
                }
            })
        }else if tag == 200 {   //正在关注
            self.data.setValue("0", forKey: "follow")
            sender.tag = 100
            sender.layer.borderColor = SeaColor.CGColor
            sender.layer.borderWidth = 1
            sender.setTitleColor(SeaColor, forState: UIControlState.Normal)
            sender.backgroundColor = UIColor.whiteColor()
            sender.setTitle("关注", forState: UIControlState.Normal)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var safeuid = Sa.objectForKey("uid") as String
                var safeshell = Sa.objectForKey("shell") as String
                var sa = SAPost("uid=\(self.uid)&&myuid=\(safeuid)&&shell=\(safeshell)&&unfo=1", "http://nian.so/api/fo.php")
                if sa != "" && sa != "err" {
                }
            })
        }
    }
}
