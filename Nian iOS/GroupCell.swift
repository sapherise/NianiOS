//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit
import QuartzCore


class GroupCell: UITableViewCell {
    
    @IBOutlet var contentLabel:UILabel!
    @IBOutlet var lastdate:UILabel!
    @IBOutlet var View:UIView!
    @IBOutlet var reply:UILabel!
    @IBOutlet var line:UIView!
    @IBOutlet var viewLine: UIView!
    
    var largeImageURL:String = ""
    var data :NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.View!.backgroundColor = BGColor
        self.line.setWidth(globalWidth)
        self.lastdate.setX(globalWidth-160)
        self.viewLine.setWidth(globalWidth - 40)
        self.contentLabel.setWidth(globalWidth-40)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        var id = self.data.stringAttributeForKey("id")
        var title = self.data.stringAttributeForKey("title")
        var lastdate = self.data.stringAttributeForKey("lastdate")
        var reply = self.data.stringAttributeForKey("reply")
        self.lastdate!.text = lastdate
        self.reply!.text = "\(reply) 回应"
        var height = title.stringHeightWith(16,width:globalWidth-40)
        self.contentLabel!.setHeight(height)
        self.contentLabel!.text = title
        self.line.setY(self.contentLabel!.bottom())
        self.viewLine.setY(self.line.bottom()+16)
    }
    
    class func cellHeightByData(data:NSDictionary)->CGFloat {
        var title = data.stringAttributeForKey("title")
        var height = title.stringHeightWith(16,width:globalWidth-40)
        return height + 74
    }
    
}
