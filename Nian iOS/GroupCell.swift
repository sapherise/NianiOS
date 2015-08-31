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
        let title = SADecode(SADecode(self.data.stringAttributeForKey("title")))
        let lastdate = self.data.stringAttributeForKey("lastdate")
        let reply = self.data.stringAttributeForKey("reply")
        self.labelTime.text = V.relativeTime(lastdate)
        self.labelComment.text = "回应 \(reply)"
        let height = title.stringHeightWith(16,width:globalWidth-40)
        self.labelContent!.setHeight(height)
        self.labelContent!.text = title
        self.line.setY(self.labelContent!.bottom())
        self.viewLine.setY(self.line.bottom()+16)
        viewLine.setHeightHalf()
    }
    
    class func cellHeightByData(data:NSDictionary)->CGFloat {
        let title = SADecode(SADecode(data.stringAttributeForKey("title")))
        let height = title.stringHeightWith(16,width:globalWidth-40)
        return height + 74
    }
    
}
