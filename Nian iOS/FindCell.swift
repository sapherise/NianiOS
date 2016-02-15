//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class FindCell: UITableViewCell {
    
    @IBOutlet var imageHead:UIImageView!
    @IBOutlet var labelNick:UILabel!
    @IBOutlet var btnFollow:UIButton!
    @IBOutlet var viewLine: UIView!
    var data: NSDictionary!
    var uid: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setWidth(globalWidth)
        self.btnFollow.setX(globalWidth-85)
        self.viewLine.setWidth(globalWidth-85)
    }
    
    func setup() {
        if self.data != nil {
            self.uid = self.data.stringAttributeForKey("uid") as String
            let follow = self.data.stringAttributeForKey("follow") as String
            self.labelNick!.text = self.data.stringAttributeForKey("user")
            self.imageHead.tag = Int(self.uid)!
            self.imageHead.setHead(uid)
            
            if follow == "0" {
                self.btnFollow.tag = 100
                self.btnFollow.layer.borderColor = UIColor.HightlightColor().CGColor
                self.btnFollow.layer.borderWidth = 1
                self.btnFollow.setTitleColor(UIColor.HightlightColor(), forState: UIControlState.Normal)
                self.btnFollow.backgroundColor = UIColor.whiteColor()
                self.btnFollow.setTitle("关注", forState: UIControlState.Normal)
            }else{
                self.btnFollow.tag = 200
                self.btnFollow.layer.borderWidth = 0
                self.btnFollow.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                self.btnFollow.backgroundColor = UIColor.HightlightColor()
                self.btnFollow.setTitle("已关注", forState: UIControlState.Normal)
            }
            self.btnFollow.addTarget(self, action: "onFollowClick:", forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    func onFollowClick(sender:UIButton){
        let tag = sender.tag
        if tag == 100 {     //没有关注
            let mutableItem = NSMutableDictionary(dictionary: data)
            mutableItem.setObject("1", forKey: "follow")
            self.data = mutableItem
            sender.tag = 200
            sender.layer.borderWidth = 0
            sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            sender.backgroundColor = UIColor.HightlightColor()
            sender.setTitle("已关注", forState: UIControlState.Normal)
            
            Api.getFollow(uid) { json in
                
            }
        }else if tag == 200 {   //正在关注
            let mutableItem = NSMutableDictionary(dictionary: data)
            mutableItem.setObject("0", forKey: "follow")
            self.data = mutableItem
            sender.tag = 100
            sender.layer.borderColor = UIColor.HightlightColor().CGColor
            sender.layer.borderWidth = 1
            sender.setTitleColor(UIColor.HightlightColor(), forState: UIControlState.Normal)
            sender.backgroundColor = UIColor.whiteColor()
            sender.setTitle("关注", forState: UIControlState.Normal)
            
            Api.getUnfollow(self.uid) { json in
            }
        }
    }
}
