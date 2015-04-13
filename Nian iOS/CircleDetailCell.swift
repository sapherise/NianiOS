//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class CircleDetailCell: MKTableViewCell {
    @IBOutlet var imageUser: UIImageView!
    @IBOutlet var imageDream: UIImageView!
    @IBOutlet var viewLine: UIView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelDream: UILabel!
    @IBOutlet var labelLevel: UILabel!
    var data :NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.setWidth(globalWidth)
        self.viewLine.setWidth(globalWidth-78)
        self.imageDream.setX(globalWidth-55)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var uid = self.data.objectForKey("uid") as! String
        var name = self.data.objectForKey("name") as! String
        var dream = self.data.objectForKey("dream") as! String
        var level = self.data.objectForKey("level") as! String
        var cover = self.data.objectForKey("dreamcover") as! String
        var title = self.data.objectForKey("title") as! String
        var theLevel = ""
        if level == "9" {
            theLevel = "组长"
            self.labelLevel.hidden = false
            self.labelName.setX(106)
        }else if level == "8" {
            theLevel = "小组长"
            self.labelLevel.hidden = false
            self.labelName.setX(106)
        }else{
            self.labelLevel.hidden = true
            self.labelName.setX(63)
        }
        self.labelName.text = "\(name)"
        var widthName = name.stringWidthWith(14, height: 22)
        self.labelName.setWidth(widthName)
        self.labelLevel.text = theLevel
        
        self.labelDream.text = "\(title)"
        self.imageUser.setHead(uid)
        self.imageDream.setImage("http://img.nian.so/dream/\(cover)!dream", placeHolder: IconColor)
        self.imageUser.tag = uid.toInt()!
        self.imageDream.tag = dream.toInt()!
    }
    
    
    class func cellHeightByData(data:NSDictionary)->CGFloat {
        return 71
    }
    
}
