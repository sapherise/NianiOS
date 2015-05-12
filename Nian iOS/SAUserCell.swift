//
//  SAUserCell.swift
//  Nian iOS
//
//  Created by Sa on 15/5/8.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import UIKit


class SAUserCell: MKTableViewCell {
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var btnMain: UIButton!
    @IBOutlet var viewLine: UIView!
    @IBOutlet var viewHolder: UIView!
    var data :NSDictionary!
    var content = ["关注", "关注中"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.imageHead.layer.cornerRadius = 20
        self.imageHead.layer.masksToBounds = true
        self.viewHolder.setWidth(globalWidth)
        self.btnMain.setX(globalWidth-85)
        self.viewLine.setWidth(globalWidth-85)
    }
    
    override func layoutSubviews() {
        var user = data.stringAttributeForKey("user")
        var uid = data.stringAttributeForKey("uid")
        var bool = data.stringAttributeForKey("follow")
        self.labelName.text = user
        self.imageHead.setHead(uid)
        if let tag = uid.toInt() {
            self.imageHead.tag = tag
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

