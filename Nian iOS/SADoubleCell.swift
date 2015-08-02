//
//  SAUserCell.swift
//  Nian iOS
//
//  Created by Sa on 15/5/8.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import UIKit


class SADoubleCell: MKTableViewCell {
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var btnMain: UIButton!
    @IBOutlet var viewLine: UIView!
    @IBOutlet var viewHolder: UIView!
    var data :NSDictionary!
    var content = ["关注", "关注中"]
    var type: Int = 0   // 当为 0 时为记本，当为 1 时为用户
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.imageHead.layer.cornerRadius = type == 0 ? 4 : 20
        self.imageHead.layer.masksToBounds = true
        self.viewHolder.setWidth(globalWidth)
        self.btnMain.setX(globalWidth-85)
        self.viewLine.setWidth(globalWidth-85)
        self.viewLine.setHeight(0.5)
    }
    
    override func layoutSubviews() {
        var id = data.stringAttributeForKey("id")
        var user = data.stringAttributeForKey("user")
        var uid = data.stringAttributeForKey("uid")
        var bool = data.stringAttributeForKey("follow")
        var img = data.stringAttributeForKey("image")
        var title = SADecode(data.stringAttributeForKey("title"))
        var des = SADecode(data.stringAttributeForKey("content"))
        self.labelName.text = type == 0 ? title : user
        self.labelContent.text = des == "" ? "暂无简介" : des
        viewLine.setHeightHalf()
        if type == 0 {
            self.imageHead.setImage("http://img.nian.so/dream/\(img)!dream", placeHolder: IconColor)
            if let tag = id.toInt() {
                self.imageHead.tag = tag
            }
        } else {
            self.imageHead.setHead(uid)
            if let tag = uid.toInt() {
                self.imageHead.tag = tag
            }
        }
        if bool == "0" {
            self.btnMain.layer.borderColor = SeaColor.CGColor
            self.btnMain.layer.borderWidth = 1
            self.btnMain.setTitleColor(SeaColor, forState: UIControlState.allZeros)
            self.btnMain.backgroundColor = UIColor.whiteColor()
            self.btnMain.setTitle(content[0], forState: UIControlState.allZeros)
        } else {
            self.btnMain.layer.borderColor = SeaColor.CGColor
            self.btnMain.layer.borderWidth = 1
            self.btnMain.setTitleColor(UIColor.whiteColor(), forState: UIControlState.allZeros)
            self.btnMain.backgroundColor = SeaColor
            self.btnMain.setTitle(content[1], forState: UIControlState.allZeros)
        }
    }
}

