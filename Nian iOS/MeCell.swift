//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class MeCell: UITableViewCell {
    
    @IBOutlet var avatarView:UIImageView?
    @IBOutlet var nickLabel:UILabel?
    @IBOutlet var wordLabel:UILabel?
    @IBOutlet var contentLabel:UILabel?
    @IBOutlet var holder:UIView?
    @IBOutlet var lastdate:UILabel?
    @IBOutlet var View:UIView?
    var largeImageURL:String = ""
    var data :NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.View!.backgroundColor = BGColor
        self.holder!.layer.cornerRadius = 4;
        self.holder!.layer.masksToBounds = true;
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        var uid = self.data.stringAttributeForKey("cuid")
        var user = self.data.stringAttributeForKey("cname")
        var lastdate = self.data.stringAttributeForKey("lastdate")
        var dreamtitle = self.data.stringAttributeForKey("dreamtitle")
        var content = self.data.stringAttributeForKey("content")
        var type = self.data.stringAttributeForKey("type")
        var word:String = ""
        
        switch type {
        case "0": word = "在「\(dreamtitle)」留言"
        case "1": word = "在「\(dreamtitle)」提到你"
        case "2": word = "赞了你的梦想「\(dreamtitle)」"
            content = "「\(dreamtitle)」"
        case "3": word = "关注了你"
            content = "去看看对方"
        case "4": word = "参与你的话题「\(dreamtitle)」"
        case "5": word = "在「\(dreamtitle)」提到你"
        case "6": word = "为你的梦想「\(dreamtitle)」更新了"
        case "7": word = "添加你为「\(dreamtitle)」的伙伴"
            content = "「\(dreamtitle)」"
        case "8": word = "赞了你的进展"
            content = dreamtitle
        default: word = "与你互动了"
        }
        
        self.nickLabel!.text = user
        self.wordLabel!.text = word
        self.lastdate!.text = lastdate
        
        var userImageURL = "http://img.nian.so/head/\(uid).jpg!head"
        self.avatarView!.setImage(userImageURL,placeHolder: IconColor)
        self.avatarView!.tag = uid.toInt()!
        
        var height = content.stringHeightWith(17,width:242)
        
        self.contentLabel!.setHeight(height)
        self.contentLabel!.text = content
        self.holder!.setHeight(height+100)
        self.View!.setHeight(110 + height)
        
    }
    
    
    
    class func cellHeightByData(data:NSDictionary)->CGFloat
    {
        
        var dreamtitle = data.stringAttributeForKey("dreamtitle")
        var content = data.stringAttributeForKey("content")
        var type = data.stringAttributeForKey("type")
        if type == "8" {
            content = dreamtitle
        }
        var height = content.stringHeightWith(17,width:242)
        return 110 + height
    }
    
}
