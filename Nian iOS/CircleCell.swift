//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit
import QuartzCore


class CircleCell: UITableViewCell {
    
    @IBOutlet var labelTitle:UILabel!
    @IBOutlet var lastdate:UILabel?
    @IBOutlet var viewLine: UIView!
    @IBOutlet var labelContent: UILabel!
    
    var largeImageURL:String = ""
    var data :NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var id = self.data.stringAttributeForKey("id")
        var title = self.data.stringAttributeForKey("title")
        var postdate = (self.data.stringAttributeForKey("postdate") as NSString).doubleValue
        var current = (self.data.stringAttributeForKey("current") as NSString).doubleValue
        var uid = self.data.stringAttributeForKey("uid")
        var content = self.data.stringAttributeForKey("content")
        var img = self.data.stringAttributeForKey("img")
        self.lastdate!.text = V.relativeTime(postdate, current: current)
        self.labelContent.text = content
        self.labelTitle.text = title
    }
    
    class func cellHeightByData(data:NSDictionary)->CGFloat
    {
        var title = data.stringAttributeForKey("title")
        var height = title.stringHeightWith(17,width:290)
        return height + 75
    }
    
}
