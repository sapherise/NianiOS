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
        viewLine.setHeightHalf()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if data != nil {
            let user = data.stringAttributeForKey("user")
            let uid = data.stringAttributeForKey("uid")
            let bool = data.stringAttributeForKey("follow")
            self.labelName.text = user
            self.imageHead.setHead(uid)
            if let tag = Int(uid) {
                self.imageHead.tag = tag
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
}

