//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit
import QuartzCore


class CircleExploreCell: UITableViewCell {
    
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var viewLine: UIView!
    @IBOutlet var labelTag: UILabel!
    @IBOutlet var labelPeople: UILabel!
    @IBOutlet var labelChat: UILabel!
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var viewLeft: UIView!
    @IBOutlet var viewRight: UIView!
    @IBOutlet var btnScan: UIButton!
    @IBOutlet var viewHolder: UIView!
    
    var largeImageURL:String = ""
    var data :NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.setWidth(globalWidth)
        self.labelTag.setX(globalWidth-64)
        self.viewLine.setWidth(globalWidth)
        self.viewHolder.setX(globalWidth/2-160)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var id = self.data.objectForKey("id") as String
        var title = self.data.objectForKey("title") as String
        var img = self.data.objectForKey("img") as String
        var tag = self.data.objectForKey("tag") as String
        var people = self.data.objectForKey("people") as String
        var content = self.data.objectForKey("content") as String
        var chat = self.data.objectForKey("chat") as String
        if let IntTag = tag.toInt() {
            self.labelTag.text = V.Tags[IntTag-1]
        }
        if var IntChat = chat.toInt() {
            if IntChat >= 1000 {
                IntChat = IntChat / 100
                var FloatChat = Float(IntChat) / 10
                chat = "\(FloatChat)K"
            }
        }
        var height = content.stringHeightWith(13, width: 250)
        self.labelPeople.text = people
        self.labelTitle.text = title
        self.labelChat.text = chat
        self.labelContent.text = content
        self.labelContent.setHeight(height)
        var bottom = self.labelContent.bottom()
        if content == "" {
            bottom = self.labelTitle.bottom()
        }
        self.viewLeft.setY(bottom + 15)
        self.viewRight.setY(bottom + 15)
        self.btnScan.setY(bottom + 84)
        self.viewLine.setY(bottom + 154)
        if img != "" {
            self.imageHead.setImage("http://img.nian.so/dream/\(img)!dream", placeHolder: IconColor)
        }else{
            self.imageHead.image = UIImage(named: "drop")
            self.imageHead.contentMode = UIViewContentMode.Center
            self.imageHead.backgroundColor = IconColor
        }
    }
    
    class func cellHeightByData(data:NSDictionary)->CGFloat {
        var content = data.stringAttributeForKey("content")
        if content == "" {
            return 301
        }
        var height = content.stringHeightWith(13, width: 250)
        return height + 309
    }
    
}
