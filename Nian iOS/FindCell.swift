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
                self.btnFollow.layer.borderColor = UIColor.HighlightColor().cgColor
                self.btnFollow.layer.borderWidth = 1
                self.btnFollow.setTitleColor(UIColor.HighlightColor(), for: UIControlState())
                self.btnFollow.backgroundColor = UIColor.white
                self.btnFollow.setTitle("关注", for: UIControlState())
            }else{
                self.btnFollow.tag = 200
                self.btnFollow.layer.borderWidth = 0
                self.btnFollow.setTitleColor(UIColor.white, for: UIControlState())
                self.btnFollow.backgroundColor = UIColor.HighlightColor()
                self.btnFollow.setTitle("已关注", for: UIControlState())
            }
            self.btnFollow.addTarget(self, action: #selector(FindCell.onFollowClick(_:)), for: UIControlEvents.touchUpInside)
        }
    }
    
    func onFollowClick(_ sender:UIButton){
        let tag = sender.tag
        if tag == 100 {     //没有关注
            let mutableItem = NSMutableDictionary(dictionary: data)
            mutableItem.setObject("1", forKey: "follow" as NSCopying)
            self.data = mutableItem
            sender.tag = 200
            sender.layer.borderWidth = 0
            sender.setTitleColor(UIColor.white, for: UIControlState())
            sender.backgroundColor = UIColor.HighlightColor()
            sender.setTitle("已关注", for: UIControlState())
            
            Api.getFollow(uid) { json in
                
            }
        }else if tag == 200 {   //正在关注
            let mutableItem = NSMutableDictionary(dictionary: data)
            mutableItem.setObject("0", forKey: "follow" as NSCopying)
            self.data = mutableItem
            sender.tag = 100
            sender.layer.borderColor = UIColor.HighlightColor().cgColor
            sender.layer.borderWidth = 1
            sender.setTitleColor(UIColor.HighlightColor(), for: UIControlState())
            sender.backgroundColor = UIColor.white
            sender.setTitle("关注", for: UIControlState())
            
            Api.getUnfollow(self.uid) { json in
            }
        }
    }
}
