//
//  SAUserCell.swift
//  Nian iOS
//
//  Created by Sa on 15/5/8.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import UIKit


class SADoubleCell: UITableViewCell {
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var btnMain: UIButton!
    @IBOutlet var viewLine: UIView!
    @IBOutlet var viewHolder: UIView!
    var data :NSDictionary!
    var content = ["关注", "已关注"]
    var type: Int = 0   // 当为 0 时为记本，当为 1 时为用户
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.imageHead.layer.cornerRadius = type == 0 ? 4 : 20
        self.imageHead.layer.masksToBounds = true
        self.viewHolder.setWidth(globalWidth)
        self.btnMain.setX(globalWidth-85)
        self.viewLine.setWidth(globalWidth-85)
        viewLine.setHeightHalf()
    }
    
    override func layoutSubviews() {
        let id = data.stringAttributeForKey("id")
        let user = data.stringAttributeForKey("user")
        let uid = data.stringAttributeForKey("uid")
        let bool = data.stringAttributeForKey("follow")
        let img = data.stringAttributeForKey("image")
        let title = data.stringAttributeForKey("title").decode()
        let des = data.stringAttributeForKey("content").decode()
        self.labelName.text = type == 0 ? title : user
        self.labelContent.text = des == "" ? "暂无简介" : des
        if type == 0 {
            self.imageHead.setImage("http://img.nian.so/dream/\(img)!dream")
            if let tag = Int(id) {
                self.imageHead.tag = tag
            }
        } else {
            self.imageHead.setHead(uid)
            if let tag = Int(uid) {
                self.imageHead.tag = tag
            }
        }
        if bool == "0" {
            self.btnMain.layer.borderColor = SeaColor.CGColor
            self.btnMain.layer.borderWidth = 1
            self.btnMain.setTitleColor(SeaColor, forState: UIControlState())
            self.btnMain.backgroundColor = UIColor.whiteColor()
            self.btnMain.setTitle(content[0], forState: UIControlState())
        } else {
            self.btnMain.layer.borderColor = SeaColor.CGColor
            self.btnMain.layer.borderWidth = 1
            self.btnMain.setTitleColor(UIColor.whiteColor(), forState: UIControlState())
            self.btnMain.backgroundColor = SeaColor
            self.btnMain.setTitle(content[1], forState: UIControlState())
        }
    }
}

