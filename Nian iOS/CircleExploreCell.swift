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
    @IBOutlet var imageHead: UIImageView!
    
    var largeImageURL:String = ""
    var data :NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        var id = self.data.objectForKey("id") as String
        var title = self.data.objectForKey("title") as String
        var img = self.data.objectForKey("img") as String
        var tag = (self.data.objectForKey("tag") as String).toInt()!
        var people = self.data.objectForKey("people") as String
        var textTag = V.Tags[tag-1]
        var width = title.stringWidthWith(14, height: 22)
        self.labelTag.text = textTag
        self.labelPeople.text = "梦境人数：\(people) 人"
        self.labelTitle.setWidth(width)
        self.labelTitle.text = title
        self.imageHead.setImage("http://img.nian.so/dream/\(img)!dream", placeHolder: IconColor)
    }
    
}
