//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class LikeCell: UITableViewCell {
    
    @IBOutlet var avatarView:UIImageView?
    @IBOutlet var nickLabel:UILabel?
    @IBOutlet var holder:UILabel?
    @IBOutlet var View:UIView?
    var LargeImgURL:String = ""
    var data :NSDictionary!
    var user:String = ""
    
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
        var uid = self.data.stringAttributeForKey("uid")
        user = self.data.stringAttributeForKey("user")
        self.nickLabel!.text = user
        
        var userImageURL = "http://img.nian.so/head/\(uid).jpg!head"
        self.avatarView!.setImage(userImageURL,placeHolder: IconColor)
        self.avatarView!.tag = uid.toInt()!
    }
}
