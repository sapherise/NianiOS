//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit
import QuartzCore


class LetterCell: UITableViewCell {
    
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
        var postdate = (self.data.stringAttributeForKey("postdate") as NSString).doubleValue
        var current = (self.data.stringAttributeForKey("current") as NSString).doubleValue
        var uid = self.data.stringAttributeForKey("uid")
        var user = self.data.stringAttributeForKey("user")
        var content = self.data.stringAttributeForKey("content")
        var count = self.data.stringAttributeForKey("count")
        var type = self.data.stringAttributeForKey("type")
        if count == "0" {
            self.labelCount.hidden = true
        }else{
            self.labelCount.hidden = false
            var widthCount = ceil(count.stringWidthWith(11, height: 20) + 16.0)
            self.labelCount.text = count
            self.labelCount.setWidth(widthCount)
            self.labelCount.setX(305-widthCount)
        }
        
        var textContent = ""
        // 1: 文字消息，2: 图片消息
        switch type {
        case "1":   textContent = "\(content)"
        case "2":   textContent = "发了一张图片"
        default:    textContent = "可以开始聊天啦"
            break
        }
        
        self.lastdate!.text = V.relativeTime(postdate, current: current)
        self.imageHead.setImage("http://img.nian.so/head/\(uid).jpg!dream", placeHolder: IconColor)
        self.labelContent.text = textContent
        self.labelTitle.text = user
    }
}