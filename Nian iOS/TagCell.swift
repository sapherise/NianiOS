//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class TagCell: UITableViewCell {
    
    @IBOutlet var avatarView:UIImageView!
    @IBOutlet var nickLabel:UILabel!
    @IBOutlet var View:UIView!
    var LargeImgURL:String = ""
    var data :NSDictionary!
    var Id:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.avatarView.layer.cornerRadius = 20
        self.avatarView.layer.masksToBounds = true
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.Id = self.data.stringAttributeForKey("id") as String
        var title = self.data.stringAttributeForKey("title") as String
        var img = self.data.stringAttributeForKey("img") as String
        self.nickLabel!.text = title
        var userImageURL = "http://img.nian.so/dream/\(img)!dream"
        self.tag = self.Id.toInt()!
        self.avatarView!.setImage(userImageURL,placeHolder: IconColor)
    }
}
