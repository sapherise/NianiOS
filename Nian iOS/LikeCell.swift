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
    @IBOutlet var viewHolder: UIView!
    @IBOutlet var viewLine: UIView!
    var LargeImgURL:String = ""
    var data :NSDictionary!
    var user:String = ""
    var uid:String = ""
    var urlIdentify:Int = 0
    var circleID:String = "0"
    var ownerID: String = "0"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.avatarView.layer.cornerRadius = 20
        self.avatarView.layer.masksToBounds = true
        self.viewHolder.setWidth(globalWidth)
        self.btnFollow.setX(globalWidth-85)
        self.viewLine.setWidth(globalWidth-85)
        viewLine.setHeight(globalHalf)
    }
    
    func _layoutSubviews() {

        self.uid = self.data.stringAttributeForKey("uid")
        let follow = self.data.stringAttributeForKey("follow")
        user = self.data.stringAttributeForKey("user")
        self.nickLabel!.text = user
        self.avatarView.setHead(uid)
        self.avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LikeCell.onUserClick)))
        
        
        let safeuid = SAUid()
        
        if self.urlIdentify == 1 && self.ownerID == safeuid {
            self.btnFollow.layer.borderWidth = 0
            self.btnFollow.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            self.btnFollow.backgroundColor = UIColor.HighlightColor()
            self.btnFollow.setTitle("写信", forState: UIControlState.Normal)
            self.btnFollow.addTarget(self, action: #selector(LikeCell.onLetterClick), forControlEvents: UIControlEvents.TouchUpInside)
        } else {
            if follow == "0" {
                self.btnFollow.tag = 100
                self.btnFollow.layer.borderColor = UIColor.HighlightColor().CGColor
                self.btnFollow.layer.borderWidth = 1
                self.btnFollow.setTitleColor(UIColor.HighlightColor(), forState: UIControlState.Normal)
                self.btnFollow.backgroundColor = UIColor.whiteColor()
                self.btnFollow.setTitle("关注", forState: UIControlState.Normal)
            }else{
                self.btnFollow.tag = 200
                self.btnFollow.layer.borderWidth = 0
                self.btnFollow.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                self.btnFollow.backgroundColor = UIColor.HighlightColor()
                self.btnFollow.setTitle("已关注", forState: UIControlState.Normal)
            }
            self.btnFollow.addTarget(self, action: #selector(LikeCell.onFollowClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    func onUserClick() {
        let vc = PlayerViewController()
        vc.Id = data.stringAttributeForKey("uid")
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onLetterClick() {
        if let uid = Int(data.stringAttributeForKey("uid")) {
            let vc = CircleController()
            vc.id = uid
            vc.name = user
            self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func onInviteClick(sender:UIButton){
    }
    
    func onFollowClick(sender:UIButton){
        let tag = sender.tag
        if tag == 100 {     //没有关注
            self.data.setValue("1", forKey: "follow")
            sender.tag = 200
            sender.layer.borderWidth = 0
            sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            sender.backgroundColor = UIColor.HighlightColor()
            sender.setTitle("已关注", forState: UIControlState.Normal)
            Api.getFollow(uid) { json in
                
            }
            
        }else if tag == 200 {   //正在关注
            self.data.setValue("0", forKey: "follow")
            sender.tag = 100
            sender.layer.borderColor = UIColor.HighlightColor().CGColor
            sender.layer.borderWidth = 1
            sender.setTitleColor(UIColor.HighlightColor(), forState: UIControlState.Normal)
            sender.backgroundColor = UIColor.whiteColor()
            sender.setTitle("关注", forState: UIControlState.Normal)
            Api.getUnfollow(self.uid) { json in
            }
        }
    }
}
