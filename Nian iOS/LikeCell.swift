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
        
        
        var tap = UITapGestureRecognizer(target: self, action: "imageViewTapped:")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews()
    {
        
        
        super.layoutSubviews()
        var uid = self.data.stringAttributeForKey("uid")
        user = self.data.stringAttributeForKey("user")
        
        self.nickLabel!.text = user
        self.View!.backgroundColor = BGColor
        
        var userImageURL = "http://img.nian.so/head/\(uid).jpg!head"
        self.avatarView!.setImage(userImageURL,placeHolder: UIImage(named: "1.jpg"))
        self.avatarView!.userInteractionEnabled = true
        self.avatarView!.tag = uid.toInt()!
        
        self.holder!.layer.cornerRadius = 4;
        self.holder!.layer.masksToBounds = true;
    }
}
