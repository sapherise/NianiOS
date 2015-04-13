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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.uid = self.data.stringAttributeForKey("uid") as String
        var follow = self.data.stringAttributeForKey("follow") as String
        self.labelNick!.text = self.data.stringAttributeForKey("user")
        self.imageHead.tag = self.uid.toInt()!
        self.imageHead.setHead(uid)
        
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
    
    func onFollowClick(sender:UIButton){
        var tag = sender.tag
        if tag == 100 {     //没有关注
            var mutableItem = NSMutableDictionary(dictionary: data)
            mutableItem.setObject("1", forKey: "follow")
            self.data = mutableItem
            sender.tag = 200
            sender.layer.borderWidth = 0
            sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            sender.backgroundColor = SeaColor
            sender.setTitle("关注中", forState: UIControlState.Normal)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var safeuid = Sa.objectForKey("uid") as! String
                var safeshell = Sa.objectForKey("shell") as! String
                var sa = SAPost("uid=\(self.uid)&&myuid=\(safeuid)&&shell=\(safeshell)&&fo=1", "http://nian.so/api/fo.php")
                if sa != "" && sa != "err" {
                }
            })
        }else if tag == 200 {   //正在关注
            var mutableItem = NSMutableDictionary(dictionary: data)
            mutableItem.setObject("0", forKey: "follow")
            self.data = mutableItem
            sender.tag = 100
            sender.layer.borderColor = SeaColor.CGColor
            sender.layer.borderWidth = 1
            sender.setTitleColor(SeaColor, forState: UIControlState.Normal)
            sender.backgroundColor = UIColor.whiteColor()
            sender.setTitle("关注", forState: UIControlState.Normal)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var safeuid = Sa.objectForKey("uid") as! String
                var safeshell = Sa.objectForKey("shell") as! String
                var sa = SAPost("uid=\(self.uid)&&myuid=\(safeuid)&&shell=\(safeshell)&&unfo=1", "http://nian.so/api/fo.php")
                if sa != "" && sa != "err" {
                }
            })
        }
    }
}
