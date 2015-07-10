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
    @IBOutlet var labelTag: UILabel! //标签
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var viewLeft: UIView!
    @IBOutlet var viewMiddle: UIView!
    @IBOutlet var viewRight: UIView!
    @IBOutlet var viewHolder: UIView!
    @IBOutlet var labelLeft: UILabel!
    @IBOutlet var labelMiddle: UILabel!
    @IBOutlet var labelRight: UILabel!
    
    var largeImageURL:String = ""
    var data :NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.setWidth(globalWidth)
        self.viewLine.setWidth(globalWidth - 32)
        self.viewHolder.setX(globalWidth/2-160)
        self.labelTag.setX(globalWidth-66)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var id = self.data.stringAttributeForKey("id")
        var title = self.data.stringAttributeForKey("title").decode()
        var img = self.data.stringAttributeForKey("image")
        var tag = self.data.stringAttributeForKey("tag")
        var people = self.data.stringAttributeForKey("people")
        var content = self.data.stringAttributeForKey("content").decode()
        var chat = self.data.stringAttributeForKey("chat")
        var step = self.data.stringAttributeForKey("step")
        var bbs = self.data.stringAttributeForKey("bbs")
        if let IntTag = tag.toInt() {
            self.labelTag.text = V.Tags[IntTag-1]
        }
        self.labelTag.setRadius(4, isTop: false)
        var heightTitle = title.stringHeightBoldWith(18, width: 240)
        var height = content.stringHeightWith(12, width: 248)
        labelLeft.text = SAThousand(step)
        labelMiddle.text = SAThousand(bbs)
        labelRight.text = SAThousand(chat)
        self.labelTitle.text = title
        self.labelTitle.setHeight(heightTitle)
        self.labelContent.text = content
        self.labelContent.setHeight(height)
        self.labelContent.setY(self.labelTitle.bottom()+8)
        var bottom = self.labelContent.bottom()
        if content == "" {
            bottom = self.labelTitle.bottom()
        }
        self.viewLeft.setY(bottom + 16)
        self.viewMiddle.setY(bottom + 16)
        self.viewRight.setY(bottom + 16)
        self.viewLine.setY(viewLeft.bottom() + 32)
        if img != "" {
            self.imageHead.setImage("http://img.nian.so/dream/\(img)!dream", placeHolder: IconColor)
        }else{
            self.imageHead.image = UIImage(named: "drop")
            self.imageHead.contentMode = UIViewContentMode.Center
            self.imageHead.backgroundColor = IconColor
        }
    }
    
    class func cellHeightByData(data:NSDictionary)->CGFloat {
        var content = data.stringAttributeForKey("content").decode()
        var title = data.stringAttributeForKey("title").decode()
        var heightTitle = title.stringHeightBoldWith(18, width: 240)
        if content == "" {
            return 205 + heightTitle - 8
        }
        var height = content.stringHeightWith(12, width: 248)
        return height + 205 + heightTitle
    }
    
}
