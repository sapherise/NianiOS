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
    
    @IBOutlet var contentLabel:UILabel?
    @IBOutlet var lastdate:UILabel?
    @IBOutlet var View:UIView?
    @IBOutlet var reply:UILabel?
    @IBOutlet var line:UIView?
    @IBOutlet var viewLine: UIView!
    
    var largeImageURL:String = ""
    var data :NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.View!.backgroundColor = BGColor
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        var id = self.data.stringAttributeForKey("id")
        var title = self.data.stringAttributeForKey("title")
        self.contentLabel?.text = title
    }
    
    class func cellHeightByData(data:NSDictionary)->CGFloat
    {
        var title = data.stringAttributeForKey("title")
        var height = title.stringHeightWith(17,width:290)
        return height + 75
    }
    
}
