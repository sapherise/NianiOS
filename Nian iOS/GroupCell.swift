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
    
    @IBOutlet var labelContent:UILabel!
    @IBOutlet var labelTime:UILabel!
    @IBOutlet var labelComment:UILabel!
    @IBOutlet var line:UIView!
    @IBOutlet var viewLine: UIView!
    
    var largeImageURL:String = ""
    var data :NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.backgroundColor = BGColor
        self.line.setWidth(globalWidth)
        self.labelTime.setX(globalWidth-160)
        self.viewLine.setWidth(globalWidth - 40)
        self.viewLine.setHeight(0.5)
        self.labelContent.setWidth(globalWidth-40)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var id = self.data.stringAttributeForKey("id")
        var title = SADecode(SADecode(self.data.stringAttributeForKey("title")))
        var lastdate = self.data.stringAttributeForKey("lastdate")
        var reply = self.data.stringAttributeForKey("reply")
        self.labelTime.text = V.relativeTime(lastdate)
        self.labelComment.text = "\(reply) 回应"
        var height = title.stringHeightWith(16,width:globalWidth-40)
        self.labelContent!.setHeight(height)
        self.labelContent!.text = title
        self.line.setY(self.labelContent!.bottom())
        self.viewLine.setY(self.line.bottom()+16)
        viewLine.setHeightHalf()
    }
    
    class func cellHeightByData(data:NSDictionary)->CGFloat {
        var title = SADecode(SADecode(data.stringAttributeForKey("title")))
        var height = title.stringHeightWith(16,width:globalWidth-40)
        return height + 74
    }
    
}
