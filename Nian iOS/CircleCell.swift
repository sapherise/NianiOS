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
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelCount: UILabel!
    
    var largeImageURL:String = ""
    var data :NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.imageHead.setImage("http://img.nian.so/dream/1_1382882371.png!dream", placeHolder: IconColor)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var id = self.data.stringAttributeForKey("id")
        var title = self.data.stringAttributeForKey("title")
        var postdate = (self.data.stringAttributeForKey("postdate") as NSString).doubleValue
        var current = (self.data.stringAttributeForKey("current") as NSString).doubleValue
        var uid = self.data.stringAttributeForKey("uid")
        var user = self.data.stringAttributeForKey("user")
        var content = self.data.stringAttributeForKey("content")
        var img = self.data.stringAttributeForKey("img")
        var count = "15"
        self.lastdate!.text = V.relativeTime(postdate, current: current)
        self.labelCount.text = count
        var widthCount = ceil(count.stringWidthWith(11, height: 20) + 16.0)
        self.labelCount.setWidth(widthCount)
        self.labelCount.setX(305-widthCount)
        self.imageHead.setImage("http://img.nian.so/dream/\(img)!dream", placeHolder: IconColor)
        if uid == "" {
            self.labelContent.text = "你成为这个梦境的一员啦"
        }else{
            self.labelContent.text = "\(user)：\(content)"
        }
        self.labelTitle.text = title
    }
}