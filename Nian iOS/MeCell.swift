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
        
        
        var tap = UITapGestureRecognizer(target: self, action: "imageViewTapped:")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews()
    {
        
//        "cuid": "<?=$row[0]?>",
//        "cname": "<?=user($row[0])?>",
//        "content": "<?=$row[2]?>",
//        "dreamtitle": "<?=$row[3]?>",
//        "dream": "<?=$row[4]?>",
//        "type": "<?=$row[5]?>",
//        "lastdate": "<?=timetoarr($row[6])?>",
//        "cid": "<?=$row[7]?>"
        
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
        case "3": word = "关注了你"
        case "4": word = "参与你的话题「\(dreamtitle)」"
        case "5": word = "在「\(dreamtitle)」提到你"
        case "6": word = "为你的梦想「\(dreamtitle)」更新了"
        case "7": word = "添加你为「\(dreamtitle)」的伙伴"
        case "8": word = "赞了你的进展"
            content = dreamtitle
        default: word = "与你互动了"
        }
        
        self.nickLabel!.text = user
        self.wordLabel!.text = word
        self.lastdate!.text = lastdate
        self.View!.backgroundColor = BGColor
        
        var userImageURL = "http://img.nian.so/head/\(uid).jpg!head"
        self.avatarView!.setImage(userImageURL,placeHolder: UIImage(named: "1.jpg"))
        
        var height = content.stringHeightWith(17,width:280)
        
        
        
        self.contentLabel!.setHeight(height)
        self.contentLabel!.text = content
        self.holder!.setHeight(height+100)
        self.View!.setHeight(110 + height)
        self.holder!.layer.cornerRadius = 4;
        self.holder!.layer.masksToBounds = true;
        
    }
    
    
    
    class func cellHeightByData(data:NSDictionary)->CGFloat
    {
        
        var dreamtitle = data.stringAttributeForKey("dreamtitle")
        var content = data.stringAttributeForKey("content")
        var type = data.stringAttributeForKey("type")
        if type == "8" {
            content = dreamtitle
        }
        var height = content.stringHeightWith(17,width:280)
        return 110 + height
    }
    
}
