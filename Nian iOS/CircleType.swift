//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class CircleTypeCell: UITableViewCell {
    @IBOutlet var imageHead:UIImageView!
    @IBOutlet var labelUser:UILabel!
    @IBOutlet var labelContent:UILabel!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var viewHolder: UIView!
    
    var data :NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.setWidth(globalWidth)
        self.viewHolder.setX(globalWidth/2-93)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var uid = self.data.objectForKey("uid") as String
        var user = self.data.objectForKey("user") as String
        var type = self.data.objectForKey("type") as String
        var content = self.data.objectForKey("content") as String
        self.imageHead.setImage("http://img.nian.so/head/\(uid).jpg!dream", placeHolder: IconColor)
        self.viewHolder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onHolderClick:"))
        self.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onHeadClick:"))
        var textContent = ""
        // 1: 文字消息，2: 图片消息，3: 进展更新，4: 成就通告，5: 用户加入，6: 管理员操作，7: 邀请用户
        
        switch type {
        case "3":   textContent = "更新了梦想"
            break
        case "4":   textContent = "获得了成就"
            break
        case "5":   textContent = ""
            break
        case "6":   textContent = ""
            break
        case "7":   textContent = ""
            break
        default:    textContent = "触发了一个彩蛋"
            break
        }
        self.labelUser.text = "\(user)\(textContent)"
        self.labelTitle.text = "\(content)"
    }
    
    func onHolderClick(sender:UITapGestureRecognizer){
        var cid = self.data.objectForKey("cid") as String
        var type = self.data.objectForKey("type") as String
        if type == "7" || type == "6" || type == "5" {
            var uid = self.data.objectForKey("cid") as String
            var UserVC = PlayerViewController()
            UserVC.Id = uid
            if let v = self.findRootViewController()?.navigationController {
                v.pushViewController(UserVC, animated: true)
            }
        }
    }
    
    func onHeadClick(sender:UITapGestureRecognizer) {
        var uid = self.data.objectForKey("uid") as String
        var UserVC = PlayerViewController()
        UserVC.Id = uid
        if let v = self.findRootViewController()?.navigationController {
            v.pushViewController(UserVC, animated: true)
        }
    }
    
}
